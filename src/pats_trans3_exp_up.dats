(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
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

staload _(*anon*) = "prelude/DATS/list.dats"

(* ****** ****** *)

staload "pats_basics.sats"

(* ****** ****** *)

staload "pats_errmsg.sats"
staload _(*anon*) = "pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans3_exp_up"

(* ****** ****** *)

staload LAB = "pats_label.sats"
staload LOC = "pats_location.sats"
macdef print_location = $LOC.print_location

staload SYN = "pats_syntax.sats"

(* ****** ****** *)

(*
** for T_* constructors
*)
staload "pats_lexing.sats"

(* ****** ****** *)

staload "pats_staexp2.sats"
staload "pats_stacst2.sats"
staload "pats_staexp2_util.sats"
staload "pats_dynexp2.sats"
staload "pats_dynexp3.sats"

(* ****** ****** *)

staload SOL = "pats_staexp2_solve.sats"

(* ****** ****** *)

staload "pats_trans3.sats"
staload "pats_trans3_env.sats"

(* ****** ****** *)

#define l2l list_of_list_vt

(* ****** ****** *)

macdef hnf = s2hnf_of_s2exp
macdef hnflst = s2hnflst_of_s2explst
macdef unhnf = s2exp_of_s2hnf
macdef unhnflst = s2explst_of_s2hnflst

(* ****** ****** *)

extern fun d2exp_trup_var (d2e0: d2exp): d3exp
extern fun d2exp_trup_cst (d2e0: d2exp): d3exp
extern fun d2exp_trup_con (d2e0: d2exp): d3exp

(* ****** ****** *)

extern
fun d2exp_trup_applst
  (d2e0: d2exp, _fun: d2exp, _arg: d2exparglst): d3exp
// end of [d2exp_trup_applst]

extern
fun d23exp_trup_applst
  (d2e0: d2exp, _fun: d3exp, _arg: d2exparglst): d3exp
// end of [d23exp_trup_applst]

(* ****** ****** *)

extern
fun d2exp_trup_arg_body (
  loc0: location, fc0: funclo, lin: int, npf: int, p2ts: p2atlst, d2e: d2exp
) : (s2hnf, p3atlst, d3exp)

(* ****** ****** *)

extern fun d2exp_trup_lam_dyn (d2e0: d2exp): d3exp
extern fun d2exp_trup_laminit_dyn (d2e0: d2exp): d3exp

(* ****** ****** *)

extern fun d2exp_trup_tup (d2e0: d2exp): d3exp
extern fun d2exp_trup_rec (d2e0: d2exp): d3exp

(* ****** ****** *)

implement
d2exp_trup
  (d2e0) = let
//
  val loc0 = d2e0.d2exp_loc
// (*
val () = begin
  print "d2exp_trup: d2e0 = "; print_d2exp d2e0; print_newline ()
end // end of [val]
// *)
val d3e0 = (
case+ d2e0.d2exp_node of
//
| D2Evar (d2v) => d2exp_trup_var (d2e0)
//
| D2Ebool (b(*bool*)) => d2exp_trup_bool (d2e0, b)
| D2Echar (c(*char*)) => d2exp_trup_char (d2e0, c)
//
| D2Ei0nt (tok) => let
    val- T_INTEGER (base, rep, sfx) = tok.token_node
  in
    d2exp_trup_i0nt (d2e0, base, rep, sfx)
  end // end of [D2Ei0nt]
| D2Ec0har (tok) => let
    val- T_CHAR (c) = tok.token_node
  in
    d2exp_trup_char (d2e0, c) // by default: char1 (c)
  end // end of [D2Ec0har]
| D2Es0tring (tok) => let
    val- T_STRING (str) = tok.token_node
  in
    d2exp_trup_string (d2e0, str)
  end // end of [D2Es0tring]
| D2Ef0loat (tok) => let
    val- T_FLOAT (_(*base*), rep, sfx) = tok.token_node
  in
    d2exp_trup_f0loat (d2e0, rep, sfx)
  end // end of [D2Ef0loat]
//
| D2Eempty () => let
    val s2f = s2exp_void_t0ype () in d3exp_empty (loc0, s2f)
  end // end of [D2Eempty]
| D2Eextval (s2f, rep) => d3exp_extval (loc0, s2f, rep)
//
| D2Ecst _ => d2exp_trup_cst (d2e0)
| D2Econ _ => d2exp_trup_con (d2e0)
//
| D2Eapps (_fun, _arg) => let
(*
    val () = (
      print "d2exp_trup: D2Eapps"; print_newline ()
    ) // end of [val]
*)
  in
    case+ _fun.d2exp_node of
    | _ => d2exp_trup_applst (d2e0, _fun, _arg)
  end // end of [D2Eapps]
//
| D2Elam_dyn _ => d2exp_trup_lam_dyn (d2e0)
| D2Elaminit_dyn _ => d2exp_trup_laminit_dyn (d2e0)
//
| D2Etup _ => d2exp_trup_tup (d2e0)
| D2Erec _ => d2exp_trup_rec (d2e0)
//
| D2Eann_type (d2e, s2f) => let
    val d3e = d2exp_trdn (d2e, s2f)
  in
    d3exp_ann_type (loc0, d3e, s2f)
  end // end of [D2Eann_type]
//
| _ => let
    val () = (
      print "d2exp_trup: loc0 = ";
      print_location (loc0); print_newline ();
      print "d2exp_trup: d2e0 = "; print_d2exp d2e0; print_newline ()
    ) // end of [val]
    val () = assertloc (false)
  in
    exit (1)
  end // end of [_]
//
) : d3exp // end of [val]
// (*
val s2f0 = d3e0.d3exp_type
val () = (
  print "d2exp_trup: d3e0.d3exp_type = "; print_s2hnf (s2f0); print_newline ()
) // end of [val]
// *)
in
//
d3e0 // the return value
//
end // end of [d2exp_trup]

(* ****** ****** *)

implement
d2explst_trup
  (d2es) = l2l (list_map_fun (d2es, d2exp_trup))
// end of [d2explst_trup]

implement
d2explstlst_trup
  (d2ess) = l2l (list_map_fun (d2ess, d2explst_trup))
// end of [d2explstlst_trup]

(* ****** ****** *)

fun d2explst_trup_arg
  (d2es: d2explst): d23explst =
  case+ d2es of
  | list_cons (d2e, d2es) => let
      val d23e = (
        if d2exp_is_varlamcst (d2e)
          then D23Ed2exp d2e else D23Ed3exp (d2exp_trup d2e)
        // end of [if]
      ) : d23exp // end of [val]
    in
      list_vt_cons (d23e, d2explst_trup_arg (d2es))
    end // end of [cons]
  | list_nil () => list_vt_nil ()
// end of [d2explst_trup_arg]

(* ****** ****** *)

fun d23explst_trup
  (d23es: d23explst): d3explst =
  case+ d23es of
  | ~list_vt_cons (d23e, d23es) => let
      val d3e = (case+ d23e of
        | ~D23Ed2exp d2e => d2exp_trup (d2e) | ~D23Ed3exp d3e => d3e
      ) : d3exp // end of [val]
    in
      list_cons (d3e, d23explst_trup (d23es))
    end // end of [cons]
  | ~list_vt_nil () => list_nil ()
// end of [d23explst_trup]

(* ****** ****** *)

fn d23explst_trdn (
  locarg: location
, d23es: d23explst, s2es: s2explst
) : d3explst = let
//
fun aux (
  d23es: d23explst, s2es: s2explst, err: &int
) : d3explst = begin
  case+ d23es of
  | ~list_vt_cons (d23e, d23es) => (
    case+ s2es of
    | list_cons (s2e, s2es) => let
        val s2f = s2exp_hnfize (s2e)
        val d3e = (case+ d23e of
          | ~D23Ed2exp (d2e) => d2exp_trdn (d2e, s2f)
          | ~D23Ed3exp (d3e) => d3exp_trdn (d3e, s2f)
        ) : d3exp // end of [val]
        val d3es = aux (d23es, s2es, err)
      in
        list_cons (d3e, d3es)
      end // end of [list_cons]
    | list_nil () => let
        val () = err := err + 1
        val () = d23exp_free (d23e)
        val () = d23explst_free (d23es)
      in
        list_nil ()
      end // end of [list_nil]
    ) // end of [list_vt_cons]
  | ~list_vt_nil () => (case+ s2es of
    | list_cons _ => let
        val () = err := err - 1 in list_nil ()
      end // end of [list_cons]
    | list_nil () => list_nil ()
    ) // end of [list_vt_nil]
end // end of [aux]
//
var err: int = 0
val d3es = aux (d23es, s2es, err)
val () = if (err != 0) then let
  val () = prerr_error3_loc (locarg)
  val () = filprerr_ifdebug "d23explst_trdn"
  val () = prerr ": arity mismatch"
  val () = if err > 0 then prerr ": less arguments are expected."
  val () = if err < 0 then prerr ": more arguments are expected."
  val () = prerr_newline ()
in
  the_trans3errlst_add (T3E_d23explst_trdn_arity (locarg, err))
end // end of [val]
in
//
d3es (* return value *)
//
end // end of [d23explst_trdn]

(* ****** ****** *)

fn d2exp_trup_var_mutabl
  (d2e0: d2exp, d2v: d2var): d3exp = let
(*
  val () = {
    val () = print "d2exp_trup_var_mutabl: d2v = "
    val () = print_d2var (d2v)
    val () = print_newline ()
    val () = print "d2exp_trup_var_mutabl: d2varset = "
    val () = print_newline ()
  } // end of [val]
*)
  val () = assertloc (false)
in
  exit (1)
end // end of [d2exp_var_mut_tr_up]

fn d2exp_trup_var_nonmut
  (d2e0: d2exp, d2v: d2var): d3exp = let
  val loc0 = d2e0.d2exp_loc
  val lin = d2var_get_linval (d2v)
  val- Some (s2f) = d2var_get_type (d2v)
(*
  val () = {
    val () = print "d2exp_trup_var_nonmut: d2v = "
    val () = print_d2var (d2v)
    val () = print_newline ()
    val () = print "d2exp_trup_var_nonmut: lin = "
    val () = print_int (lin)
    val () = print_newline ()
    val () = print "d2exp_trup_var_nonmut: d2varset = "
    val () = print_newline ()
  } // end of [val]
*)
in
  d3exp_var (loc0, s2f, d2v)
end // end of [d2exp_trup_var_nonmut]

implement
d2exp_trup_var
  (d2e0) = let
  val- D2Evar (d2v) = d2e0.d2exp_node
in
  if d2var_is_mutable (d2v) then
    d2exp_trup_var_mutabl (d2e0, d2v)
  else
    d2exp_trup_var_nonmut (d2e0, d2v)
  // end of [if]
end // end of [d2exp_trup_var]

(* ****** ****** *)

implement
d2exp_trup_cst (d2e0) = let
  val loc0 = d2e0.d2exp_loc
  val- D2Ecst (d2c) = d2e0.d2exp_node
  val s2f = d2cst_get_type (d2c)
in
  d3exp_cst (loc0, s2f, d2c)
end // end of [d2cst_trup_cst]

(* ****** ****** *)

implement
d2exp_trup_con (d2e0) = let
  val loc0 = d2e0.d2exp_loc
  val- D2Econ (d2c, s2as, npf, locarg, d2es) = d2e0.d2exp_node
  val d23es = d2explst_trup_arg (d2es)
(*
  val () = d23explst_open_and_add (d23es)
*)
  val s2f = d2con_get_type (d2c)
  var err: int = 0
  val s2f = s2exp_uni_instantiate_sexparglst (s2f, s2as, err)
  // HX: [err] is not used
  var err: int = 0
  val locarg = $LOC.location_rightmost (loc0)
  val s2f = s2hnf_uni_instantiate_all (s2f, locarg, err)
  // HX: [err] is not used
  val s2e = (unhnf)s2f
in
//
case+ s2e.s2exp_node of
| S2Efun (
    _fc, _lin, _s2fe, npf_con, s2es_arg, s2e_res
  ) => let
    val err = $SOL.pfarity_equal_solve (loc0, npf_con, npf)
    val () = if err != 0 then let
      val () = prerr_error3_loc (loc0)
      val () = filprerr_ifdebug "d2exp_trup_con"
      val () = prerr ": proof arity mismatching: the constructor ["
      val () = prerr_d2con (d2c)
      val () = prerrf ("] requires %i arguments.", @(npf_con))
      val () = prerr_newline ()
    in
      the_trans3errlst_add (T3E_d2exp_trup_con_npf (d2e0, npf)) // nothing
    end // end of [val]
    val s2f_res = s2exp_hnfize(s2e_res)
    val d3es = d23explst_trdn (locarg, d23es, s2es_arg)
  in
    d3exp_con (loc0, s2f_res, d2c, npf, d3es)
  end // end of [S2Efun]
| _ => let
    val () = d23explst_free (d23es) in d3exp_err (loc0)
  end // end of [_]
//
end // end [d2exp_trup_con]

(* ****** ****** *)

implement
d2exp_trup_applst
  (d2e0, d2e_fun, d2as_arg) = let
  val d3e_fun = d2exp_trup (d2e_fun)
(*
  val () = d3exp_open_and_add (d3e_fun)
*)
in
  d23exp_trup_applst (d2e0, d3e_fun, d2as_arg)
end // end of [d2exp_trup_applst]

(* ****** ****** *)

fun
d23exp_trup_applst_sta (
  d2e0: d2exp
, d3e_fun: d3exp
, s2as: s2exparglst
, d2as: d2exparglst
) : d3exp = let
//
  val () = (
    print "d23exp_trup_applst_sta: d2e0 = "; print_d2exp d2e0; print_newline ()
  ) // end of [val]
//
  val loc_fun = d3e_fun.d3exp_loc
  val s2f_fun = d3e_fun.d3exp_type
  val loc_app =
    aux (loc_fun, s2as) where {
    fun aux (
      loc: location, s2as: s2exparglst
    ) : location = case+ s2as of
      | list_cons _ => let
          val s2a = list_last<s2exparg> (s2as)
        in
          $LOC.location_combine (loc, s2a.s2exparg_loc)
        end // end of [list_cons]
      | list_nil () => loc
  } // end of [where]
//
  var err: int = 0
  val s2f_fun =
    s2exp_uni_instantiate_sexparglst (s2f_fun, s2as, err)
  // end of [val]
  val () = if (err > 0) then let
    val () = prerr_error3_loc (loc_app)
    val () = filprerr_ifdebug "d2exp_trup_applst_sta"
    val () = prerr ": static application cannot be properly typechecked."
    val () = prerr_newline ()    
  in
    the_trans3errlst_add (
      T3E_s2hnf_uni_instantiate_sexparglst (loc_app, s2f_fun, s2as)
    ) // end of [the_trans3errlst_add]
  end // end of [val]
//
  val d3e_fun = d3exp_app_sta (loc_app, s2f_fun, d3e_fun)
in
  d23exp_trup_applst (d2e0, d3e_fun, d2as)
end // end of [d2exp_trup_applst_sta]

fun d23exp_trup_app23 (
  d2e0: d2exp
, d3e_fun: d3exp
, npf: int, locarg: location, d23es_arg: d23explst
) : d3exp = let
  val loc_fun = d3e_fun.d3exp_loc
  val s2f_fun = d3e_fun.d3exp_type
// (*
  val () = begin
    print "d23exp_trup_app23: s2f_fun = "; print_s2hnf s2f_fun; print_newline ()
  end // end of [val]
// *)
  var err: int = 0
  val locsarg = $LOC.location_rightmost (loc_fun)
  val s2f_fun = s2hnf_uni_instantiate_all (s2f_fun, locsarg, err)
  // HX: [err] is unused
// (*
  val () = begin
    print "d23exp_trup_app23: s2f_fun = "; print_s2hnf s2f_fun; print_newline ()
  end // end of [val]
// *)
  val d3e_fun = d3exp_app_sta (loc_fun, s2f_fun, d3e_fun)
  val s2e_fun = (unhnf)s2f_fun
  val loc_app = $LOC.location_combine (loc_fun, locarg)
in
//
case+ s2e_fun.s2exp_node of
| S2Efun (
    fc, _(*lin*), s2fe_fun, npf_fun, s2es_fun_arg, s2e_fun_res
  ) => let
(*
    val () = begin
      print "d23exp_trup_app: s2e_fun = "; print_s2exp s2e_fun; print_newline ();
      print "d23exp_trup_app: s2fe_fun = "; print_s2eff s2fe_fun; print_newline ();
      printf ("d23exp_app_tr_up: npf = %i and npf_fun = %i", @(npf, npf_fun));
      print_newline ()
    end // end of [val]
*)
//
    val err = $SOL.pfarity_equal_solve (loc_fun, npf_fun, npf)
    val () = if err != 0 then let
      val () = prerr_error3_loc (loc_fun)
      val () = filprerr_ifdebug "d23exp_trup_app23"
      val () = prerr ": proof arity mismatching"
      val () = prerrf (": the function requires %i proof arguments.", @(npf_fun))
      val () = prerr_newline ()
    in
      the_trans3errlst_add (T3E_d23exp_trup_app23_npf (loc_fun, npf))
    end // end of [val]
//
    val d3es_arg = d23explst_trdn (locarg, d23es_arg, s2es_fun_arg)
    val s2f_fun_res = s2exp_hnfize (s2e_fun_res)
    var s2f_res: s2hnf = s2f_fun_res
(*
    var wths2es
      : wths2explst = WTHS2EXPLSTnil ()
    // end of [var]
    val iswth = s2exp_is_wth (s2e_fun_res)
    val () = if iswth then let
      val s2e_fun_res =
        s2exp_opnexi_and_add (loc_app, s2e_fun_res)
      val- S2Ewth (s2e, wths2es1) = s2e_fun_res.s2exp_node
    in
      s2e_res := s2e; wths2es := wths2es1
    end : void // end of [val]
    val d3e_fun = d3exp_funclo_restore (fc, d3e_fun)
    val d3es_arg = (
      if iswth then d3explst_arg_restore (d3es_arg, wths2es) else d3es_arg
    ) : d3explst
    val () = the_effect_env_check_seff (loc_app, s2fe_fun)
*)
  in
    d3exp_app_dyn (loc_app, s2f_res, s2fe_fun, d3e_fun, npf, d3es_arg)
  end // end of [S2Efun]
| _ => let
    val () = d23explst_free (d23es_arg)
    val () = prerr_error3_loc (loc_fun)
    val () = filprerr_ifdebug "d23exp_trup_app23"
    val () = prerr ": the applied dynamic expression is not assigned a function type."
    val () = prerr_newline ()
  in
    d3exp_err (loc_fun)
  end // end of [_]
//
end // end of [d23exp_trup_app23]

fun d23exp_trup_applst_dyn (
  d2e0: d2exp
, d3e_fun: d3exp
, npf: int, locarg: location, d2es_arg: d2explst
, d2as: d2exparglst
) : d3exp = let
  val loc_fun = d3e_fun.d3exp_loc
  val loc_app = $LOC.location_combine (loc_fun, locarg)
  val s2f_fun = d3e_fun.d3exp_type
  val s2e_fun = (unhnf)s2f_fun
in
//
case+ s2e_fun.s2exp_node of
| _ => let
    val d23es_arg = d2explst_trup_arg (d2es_arg)
(*
    val () = d23explst_open_and_add (d23es_arg)
*)
    val d3e_fun = d23exp_trup_app23 (d2e0, d3e_fun, npf, locarg, d23es_arg)
  in
    d23exp_trup_applst (d2e0, d3e_fun, d2as)
  end // end of [_]
//
end // end of [d2exp_trup_applst_dyn]

implement
d23exp_trup_applst (
  d2e0: d2exp
, d3e_fun: d3exp, d2as: d2exparglst
) : d3exp = let
in
//
case+ d2as of
| list_cons (d2a, d2as) => (
  case+ d2a of
  | D2EXPARGsta (s2as) => begin
      d23exp_trup_applst_sta (d2e0, d3e_fun, s2as, d2as)
    end // end of [D2EXPARGsta]
  | D2EXPARGdyn (npf, locarg, d2es_arg) => begin
      d23exp_trup_applst_dyn (d2e0, d3e_fun, npf, locarg, d2es_arg, d2as)
    end // end of [D2EXPARGdyn]
  ) // end of [cons]
| list_nil () => d3e_fun
//
end // end of [d2exp_apps_tr_up]

(* ****** ****** *)

implement
d2exp_trup_arg_body (
  loc0
, fc0, lin, npf
, p2ts_arg, d2e_body
) = let
// (*
val FNAME = "d2exp_trup_arg_body"
val () = (
  printf ("%s: npf = ", @(FNAME));
  print_int (npf); print_newline ()
) // end of [val]
val () = (
  printf ("%s: arg = ", @(FNAME));
  print_p2atlst (p2ts_arg); print_newline ()
) // end of [val]
val () = (
  printf ("%s: body = ", @(FNAME));
  print_d2exp (d2e_body); print_newline ()
) // end of [val]
// *)
val (pfpush | ()) = trans3_env_push ()
//
var fc: funclo = fc0
var s2fe: s2eff = S2EFFnil ()
val d2e_body = d2exp_s2eff_of_d2exp (d2e_body, s2fe)
//
val s2fs_arg = p2atlst_syn_type (p2ts_arg)
val p3ts_arg = p2atlst_trup_arg (npf, p2ts_arg)
val d3e_body = d2exp_trup (d2e_body)
//
val () = trans3_env_pop_and_add_main (pfpush | (*none*))
//
val s2f_res = d3e_body.d3exp_type
val isprf = s2exp_is_prf ((unhnf)s2f_res)
val islin = lin > 0
val s2t_fun = s2rt_prf_lin_fc (loc0, isprf, islin, fc)
val s2e_fun = s2exp_fun_srt (
  s2t_fun, fc, lin, s2fe, npf, (unhnflst)s2fs_arg, (unhnf)s2f_res
) // end of [val]
//
in
//
(s2e_fun, p3ts_arg, d3e_body)
//
end // end of [d2exp_trup_arg_body]

(* ****** ****** *)

implement
d2exp_trup_lam_dyn (d2e0) = let
  val loc0 = d2e0.d2exp_loc
  val- D2Elam_dyn (lin, npf, p2ts_arg, d2e_body) = d2e0.d2exp_node
  val fc0 = FUNCLOfun () // default
  val s2ep3tsd3e = d2exp_trup_arg_body (loc0, fc0, lin, npf, p2ts_arg, d2e_body)
  val s2f_fun = s2ep3tsd3e.0
  val p3ts_arg = s2ep3tsd3e.1
  val d3e_body = s2ep3tsd3e.2
in
  d3exp_lam_dyn (loc0, s2f_fun, lin, npf, p3ts_arg, d3e_body)
end // end of [D2Elam_dyn]

implement
d2exp_trup_laminit_dyn (d2e0) = let
  val loc0 = d2e0.d2exp_loc
  val- D2Elaminit_dyn (lin, npf, p2ts_arg, d2e_body) = d2e0.d2exp_node
  val fc0 = FUNCLOclo (0) // default
  val s2ep3tsd3e = d2exp_trup_arg_body (loc0, fc0, lin, npf, p2ts_arg, d2e_body)
  val s2f_fun = s2ep3tsd3e.0
  val p3ts_arg = s2ep3tsd3e.1
  val d3e_body = s2ep3tsd3e.2
  val s2e_fun = (unhnf)s2f_fun
  val () = (
    case+ s2e_fun.s2exp_node of
    | S2Efun (fc, _, _, _, _, _) => (case+ fc of
      | FUNCLOclo 0 => ()
      | _ => let
         val () = prerr_error3_loc (loc0)
         val () = filprerr_ifdebug "d2exp_trup_laminit_dyn"
         val () = prerr ": the initializing value is expected to be a flat closure but it is not."
         val () = prerr_newline ()
       in
         the_trans3errlst_add (T3E_d2exp_trup_laminit_fc (d2e0, fc))
       end // end of [_]
      ) // end of [S2Efun]
    | _ => () // HX: deadcode
  ) : void // end of [val]
in
  d3exp_laminit_dyn (loc0, s2f_fun, lin, npf, p3ts_arg, d3e_body)
end // end of [D2Elam_dyn]

(* ****** ****** *)

extern
fun d3explst_get_type (d3es: d3explst): labs2explst

implement
d3explst_get_type (d3es) = let
  fun aux (
    d3es: d3explst, i: int
  ) : labs2explst =
    case+ d3es of
    | list_cons (d3e, d3es) => let
        val l = $LAB.label_make_int (i)
        val s2f = d3e.d3exp_type
        val ls2e = SLABELED (l, None, (unhnf)s2f)
      in
        list_cons (ls2e, aux (d3es, i+1))
      end
    | list_nil () => list_nil ()
  // end of [aux]
in
  aux (d3es, 0)
end // end of [d3explst_get_type]

implement
d2exp_trup_tup
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc
  val- D2Etup (tupknd, npf, d2es) = d2e0.d2exp_node
  val () = begin
    print "d2exp_trup_tup: d2es = "; print_d2explst d2es; print_newline ()
  end // end of [val]
//
  val d3es = d2explst_trup (d2es)
//
  val ls2es = d3explst_get_type (d3es)
  val s2f_tup = s2exp_tyrec (tupknd, npf, ls2es)
//
in
  d3exp_tup (loc0, s2f_tup, tupknd, npf, d3es)
end // end of [d2exp_trup_tup]

(* ****** ****** *)

extern
fun labd3explst_get_type (ld3es: labd3explst): labs2explst

implement
labd3explst_get_type (ld3es) = let
  fn f (
    ld3e: labd3exp
  ) : labs2exp = let
    val $SYN.DL0ABELED (l, d3e) = ld3e in
    SLABELED (l.l0ab_lab, None, unhnf(d3e.d3exp_type))
  end // end of [f]
in
  l2l (list_map_fun (ld3es, f))
end // end of [labd3explst_get_type]

implement
d2exp_trup_rec
  (d2e0) = let
  val loc0 = d2e0.d2exp_loc
  val- D2Erec (recknd, npf, ld2es) = d2e0.d2exp_node
  val () = begin
    print "d2exp_trup_rec: ld2es = "; print_labd2explst ld2es; print_newline ()
  end // end of [val]
//
  fun aux (
    ld2es: labd2explst
  ) : labd3explst =
    case+ ld2es of
    | list_cons (ld2e, ld2es) => let
        val $SYN.DL0ABELED (l, d2e) = ld2e
        val ld3e = $SYN.DL0ABELED (l, d2exp_trup (d2e))
        val ld3es = aux (ld2es)
      in
        list_cons (ld3e, ld3es)
      end // end of [list_cons]
    | list_nil () => list_nil ()
  val ld3es = aux ld2es
//
  val ls2es = labd3explst_get_type (ld3es)
  val s2f_rec = s2exp_tyrec (recknd, npf, ls2es)
//
in
  d3exp_rec (loc0, s2f_rec, recknd, npf, ld3es)
end // end of [d2exp_trup_rec]

(* ****** ****** *)

(* end of [pats_trans3_exp_up.dats] *)
