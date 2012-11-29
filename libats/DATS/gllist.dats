(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2012 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
** later version.
**
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
**
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)
//
// Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
// Time: October, 2010
//
(* ****** ****** *)
//
// HX: generic functional lists (fully indexed)
//
(* ****** ****** *)
//
// HX-2012-11-28: ported to ATS/Postiats from ATS/Anairiats
//
(* ****** ****** *)

#define ATS_STALOADFLAG 0 // no need for staloading at run-time

(* ****** ****** *)

staload "libats/SATS/ilist_prf.sats"

(* ****** ****** *)

staload "libats/SATS/gllist.sats"

(* ****** ****** *)

implement{a}
gllist_length (xs) = let
//
fun loop
  {xs:ilist}{j:int} .<xs>. (
  xs: !gllist (a, xs), j: int j
) :<> [i:nat]
  (LENGTH (xs, i) | int (i+j)) = let
in
//
case+ xs of
| gllist_cons
    (_, xs) => let
    val (pf | res) = loop (xs, j+1)
  in
    (LENGTHcons (pf) | res)
  end // end of [gllist_cons]
| gllist_nil () => (LENGTHnil () | j)
//
end // end of [loop]
//
in
  loop (xs, 0)
end // end of [gllist_length]

(* ****** ****** *)

implement{a}
gllist_append
  (xs, ys) = let
//
fun loop
  {xs:ilist}
  {ys:ilist} .<xs>. (
  xs: gllist (a, xs), ys: gllist (a, ys), res: &ptr? >> gllist (a, zs)
) :<!wrt> #[zs:ilist] (APPEND (xs, ys, zs) | void) = let
in
//
case+ xs of
| @gllist_cons
    (x, xs1) => let
    val () = res := xs
    val xs = xs1
    val (pf | ()) = loop (xs, ys, xs1)
    prval () = fold@ (res)
  in
    (APPENDcons (pf) | ())
  end // end of [gllist_cons]
| ~gllist_nil () => let
    val () = res := ys in (APPENDnil () | ())
  end // end of [gllist_nil]
//
end // end of [loop]
//
var res: ptr // uninitialized
//
val (pf | ()) = loop (xs, ys, res)
//
in
  (pf | res)
end // end of [gllist_append]

(* ****** ****** *)

implement{a}
gllist_revapp
  (xs, ys) = let
in
//
case+ xs of
| @gllist_cons
    (x, xs1) => let
    val xs1_ = xs1
    val () = xs1 := ys
    prval () = fold@ (xs)
    val (pf | res) = gllist_revapp (xs1_, xs)
  in
    (REVAPPcons (pf) | res)
  end // end of [gllist_cons]
| ~gllist_nil () => (REVAPPnil () | ys)
//
end // end of [gllist_append]

implement{a}
gllist_reverse (xs) = gllist_revapp (xs, gllist_nil)

(* ****** ****** *)
//
// HX-2012-11-28: mergesort on gllist // ported from ATS/Anairiats
//
(* ****** ****** *)

local

fun{
a:vt0p
} split
  {xs:ilist}
  {n,i:nat | i <= n} .<i>. (
  pflen: LENGTH (xs, n)
| xs: &gllist (a, xs) >> gllist (a, xs1), i: int i
) : #[xs1,xs2:ilist] (
  APPEND (xs1, xs2, xs), LENGTH (xs1, i) | gllist (a, xs2)
) =
  if i > 0 then let
    prval LENGTHcons (pflen) = pflen
    val @gllist_cons (_, xs1) = xs
    val (pfapp, pf1len | xs2) = split (pflen | xs1, i-1)
    prval () = fold@ (xs)
  in
    (APPENDcons (pfapp), LENGTHcons (pf1len) | xs2)
  end else let
    val xs2 = xs
    val () = xs := gllist_nil ()
    prval pfapp = append_unit1 ()
  in
    (pfapp, LENGTHnil () | xs2)
  end // end of [if]
// end of [split]

(* ****** ****** *)

absprop UNION (
  ys1: ilist, ys2: ilist, res: ilist
) // end of [absprop]

extern
prfun union_commute
  {ys1,ys2:ilist} {ys:ilist}
  (pf: UNION (ys1, ys2, ys)): UNION (ys2, ys1, ys)
// end of [union_commute]

extern
prfun union_nil1 {ys:ilist} (): UNION (ilist_nil, ys, ys)
extern
prfun union_nil2 {ys:ilist} (): UNION (ys, ilist_nil, ys)

extern
prfun union_cons1
  {y:int}
  {ys1,ys2:ilist}
  {ys:ilist} (
  pf: UNION (ys1, ys2, ys)
) : UNION (ilist_cons (y, ys1), ys2, ilist_cons (y, ys))
// end of [union_cons1]

extern
prfun union_cons2
  {y:int}
  {ys1,ys2:ilist}
  {ys:ilist} (
  pf: UNION (ys1, ys2, ys)
) : UNION (ys1, ilist_cons (y, ys2), ilist_cons (y, ys))
// end of [union_cons2]

extern
prfun isord_union_cons
  {y1,y2:int | y1 <= y2}
  {ys1,ys2:ilist} {ys:ilist} (
  pf1: ISORD (ilist_cons (y1, ys1))
, pf2: ISORD (ilist_cons (y2, ys2))
, pf3: UNION (ys1, ilist_cons (y2, ys2), ys)
, pf4: ISORD (ys)
) : ISORD (ilist_cons (y1, ys))

(* ****** ****** *)

fun{
a:vt0p
} merge {
  ys1,ys2:ilist
} (
  pf1ord: ISORD (ys1)
, pf2ord: ISORD (ys2)
| ys1: gllist (a, ys1), ys2: gllist (a, ys2)
, ys: &ptr? >> gllist (a, ys)
) : #[ys:ilist] (UNION (ys1, ys2, ys), ISORD (ys) | void) =
  case+ ys1 of
  | @gllist_cons (
      y1, ys1_tl
    ) => (
    case+ ys2 of
    | @gllist_cons (
        y2, ys2_tl
      ) => let
        val sgn = gllist_mergesort$cmp (y1, y2)
      in
        if sgn <= 0 then let
          val () = ys := ys1; val ys1 = ys1_tl
          prval () = fold@ (ys2)
          prval ISORDcons (pf1ord1, _) = pf1ord
          val (pfuni, pford | ()) = merge (pf1ord1, pf2ord | ys1, ys2, ys1_tl)
          prval pford = isord_union_cons (pf1ord, pf2ord, pfuni, pford)
          prval () = fold@ (ys)
          prval pfuni = union_cons1 (pfuni)
        in
          (pfuni, pford | ())
        end else let
          prval () = fold@ (ys1)
          val () = ys := ys2; val ys2 = ys2_tl
          prval ISORDcons (pf2ord1, _) = pf2ord
          val (pfuni, pford | ()) = merge (pf1ord, pf2ord1 | ys1, ys2, ys2_tl)
          prval pfuni = union_commute (pfuni)
          prval pford = isord_union_cons (pf2ord, pf1ord, pfuni, pford)
          prval () = fold@ (ys)
          prval pfuni = union_cons1 (pfuni)
          prval pfuni = union_commute (pfuni)
        in
          (pfuni, pford | ())
        end // end of [if]
      end // end of [gllist_cons]
    | ~gllist_nil () => let
        val () = fold@ (ys1); val () = ys := ys1 in (union_nil2 (), pf1ord | ())
      end // end of [gllist_nil]
    ) // end of [gllist_cons]
  | ~gllist_nil () => let
      val () = ys := ys2 in (union_nil1 (), pf2ord | ())
    end // end of [gllist_nil]
// end of [merge]

(* ****** ****** *)

extern
prfun sort_nilsing
  {xs:ilist} {n:nat | n <= 1} (pf: LENGTH (xs, n)): SORT (xs, xs)
// end of [sort_nilsing]

fun{
a:vt0p
} msort
  {xs:ilist}
{n:nat} .<n>. (
  pflen: LENGTH (xs, n)
| xs: gllist (a, xs), n: int n
) : [ys:ilist] (
  SORT (xs, ys) | gllist (a, ys)
) = let
in
//
if n >= 2 then let
  var xs = xs
  val n2 = n/2
  val (pfapp, pf1len | xs2) = split (pflen | xs, n2)
  val xs1 = xs
  prval pf2len = length_istot ()
  prval pflen_alt = lemma_append_length (pfapp, pf1len, pf2len)
  prval () = length_isfun (pflen, pflen_alt)
  val (pf1srt | ys1) = msort (pf1len | xs1, n2)
  prval (pf1ord, pf1perm) = sort_elim (pf1srt)
  val (pf2srt | ys2) = msort (pf2len | xs2, n-n2)
  prval (pf2ord, pf2perm) = sort_elim (pf2srt)
  val (pfuni, pford | ()) = merge (pf1ord, pf2ord | ys1, ys2, xs)
  prval pfperm = lemma (pfapp, pf1perm, pf2perm, pfuni) where {
    extern prfun lemma {xs1,xs2:ilist} {xs:ilist} {ys1,ys2:ilist} {ys:ilist} (
      pfapp: APPEND (xs1, xs2, xs), pf1: PERMUTE (xs1, ys1), pf2: PERMUTE (xs2, ys2), pf4: UNION (ys1, ys2, ys)
    ) : PERMUTE (xs, ys)
  } // end of [prval]
  prval pfsrt = sort_make (pford, pfperm)
in
  (pfsrt | xs)
end else
  (sort_nilsing (pflen) | xs)
// end of [if]
//
end // end of [msort]

in // in of [local]

implement{a}
gllist_mergesort (xs) = let
  val (pflen | n) = gllist_length<a> (xs) in msort<a> (pflen | xs, n)
end // end of [mergesort]

end // end of [local]

(* ****** ****** *)

(* end of [gllist.dats] *)
