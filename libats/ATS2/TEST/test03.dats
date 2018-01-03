(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
#include
"share/atspre_staload_libats_ML.hats"
//
(* ****** ****** *)
//
#staload FC =
"libats/ATS2/SATS/fcntainer2.sats"
//
#staload _(*FC*) =
"libats/ATS2/DATS/fcntainer2.dats"
#staload _(*FC*) =
"libats/ATS2/DATS/fcntainer2_intrange.dats"
//
(* ****** ****** *)

typedef
intrange = $FC.intrange

(* ****** ****** *)
//
val xs =
$FC.INTRANGE(0, 6)
//
val () =
$FC.foreach_cloref<intrange><int>(xs, lam(x) =<1> println!(x))
val () =
$FC.rforeach_cloref<intrange><int>(xs, lam(x) =<1> println!(x))
//
val () =
$FC.iforeach_cloref<intrange><int>(xs, lam(i, x) =<1> println!(i, "->", x))
//
val res =
$FC.foldleft_cloref<int><intrange><int>(xs, 0(*ini*), lam(res, x) => res + x)
val ((*void*)) =
println! ("foldleft(res) = ", res)
//
val res =
$FC.ifoldleft_cloref<int><intrange><int>(xs, 0(*ini*), lam(res, i, x) => res + i*x)
val ((*void*)) =
println! ("ifoldleft(res) = ", res)
//
(* ****** ****** *)

implement main0((*void*)) = ((*void*))

(* ****** ****** *)

(* end of [test03.dats] *)