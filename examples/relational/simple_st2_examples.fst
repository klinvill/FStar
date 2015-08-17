(*--build-config
    options:--admit_fsi Set;
    variables:LIB=../../lib;
    other-files:$LIB/ext.fst $LIB/set.fsi $LIB/heap.fst $LIB/st.fst $LIB/st2.fst $LIB/all.fst
  --*)

module Samples
open Comp
open Heap
open Relational

let f x = x := !x - !x
let g x = x := 0
val equiv1: x:ref int
         -> y:ref int
         -> ST2 (rel unit unit)
                (requires (fun _ -> True)) //x, y may be high-references
                (ensures (fun _ _ h2' -> sel (R.l h2') x == sel (R.r h2') y)) //their contents are equal afterwards
let equiv1 x y = compose2 f g x y


let square x = x := !x * !x
val equiv2: x:ref int
         -> y:ref int
         -> ST2 (rel unit unit)
                (requires (fun h2 -> sel (R.l h2) x = - (sel (R.r h2) y)))     //x, y negatives of each other
                (ensures (fun _ _ h2' -> sel (R.l h2') x = sel (R.r h2') y)) //their contents are equal afterwards
let equiv2 x y = compose2 square square x y


let f3 x = if !x = 0 then x := 0 else x:= 1
let g3 x = if !x <> 0 then x := 1 else x:= 0
val equiv3: x:ref int
         -> y:ref int
         -> ST2 (rel unit unit)
                (requires (fun h -> sel (R.l h) x = sel (R.r h) y)) // x, y have twice values
                (ensures (fun _ _ h2' -> sel (R.l h2') x = sel (R.r h2') y)) // their contents are equal afterwards
let equiv3 x y = compose2 f3 g3 x y


let f4 x = if !x = 0 then x := 0 else x:= 1
let g4 x = if !x = 0 then x := 1 else x:= 0
val equiv4: x:ref int
         -> y:ref int
         -> ST2 (rel unit unit)
                (requires (fun h -> if sel (R.l h) x = 0 then sel (R.r h) y = 1 else sel (R.r h) y = 0)) // making sure !x=0 <==> !y <> 0
                (ensures (fun _ _ h2' -> sel (R.l h2') x = sel (R.r h2') y)) //their contents are equal afterwards
let equiv4 x y = compose2 f4 g4 x y


let f5 x = x := 0
let g5 x = if !x = 0 then x := !x else x:= !x - !x
val equiv5: x:ref int
         -> y:ref int
         -> ST2 (rel unit unit)
                (requires (fun _ -> True))  // no requirements
                (ensures (fun _ _ h2' -> sel (R.l h2') x = sel (R.r h2') y)) //their contents are equal afterwards
let equiv5 x y = compose2 f5 g5 x y


let f6 x = let y = 1 in x := y
let g6 x = if !x = 0 then x := 1 else if !x <> 0 then x := 1 else x:= 0
val equiv6: x:ref int
         -> y:ref int
         -> ST2 (rel unit unit)
                (requires (fun _ -> True)) // no requirements
                (ensures (fun _ _ h2' -> sel (R.l h2') x = sel (R.r h2') y)) //their contents are equal afterwards
let equiv6 x y = compose2 f6 g6 x y


let f7 x = x := 2*!x
let g7 x = let y = (fun a -> a + a) !x in x := y
val equiv7: x:ref int
         -> y:ref int
         -> ST2 (rel unit unit)
                (requires (fun h -> sel (R.l h) x - sel (R.r h) y = 10)) // values of x, y differ by 10
                (ensures (fun _ _ h2' -> sel (R.l h2') x - sel (R.r h2') y = 20)) // values of x, y differ by 20
let equiv7 x y = compose2 f7 g7 x y


let f8 (x, y, z) = if !z=0 then (x := 1; y := 1) else (y:=1 ; x := 0)
val equiv8: a:(ref int * ref int * ref int)
         -> b:(ref int * ref int * ref int)
         -> ST2 (rel unit unit)
                (requires (fun h -> MkTuple3._1 a <> MkTuple3._2 a /\  // x and y are not aliases
                                    MkTuple3._1 b <> MkTuple3._2 b))
                (ensures (fun _ _ h2' -> sel (R.l h2') (MkTuple3._2 a) = sel (R.r h2') (MkTuple3._2 b))) //value of y is the twice
let equiv8 a b = compose2 f8 f8 a b




(* Examples taken from the POPL paper *)

let assign x y = x := y

val monotonic_assign : x:ref int -> y1:int -> y2:int
                       -> ST2 (rel unit unit)
                                     (requires (fun h -> y1 <= y2))
                                     (ensures (fun h1 r h2 -> sel (R.l h2) x <= sel (R.r h2) x))
let monotonic_assign x y1 y2 = compose2 (assign x) (assign x) y1 y2

val id : int -> Tot int
let id x = x

val monotonic_id_standard : x:int -> y:int
                            -> Lemma (requires (x <= y))
                                     (ensures (id x <= id y))
let monotonic_id_standard x y = ()


(* This does not work...? *)
(* val monotonic_id : x:int -> y:int -> ST2 (rel int int) *)
(*                                                 (requires (fun h -> x <= y)) *)
(*                                                 (ensures (fun h1 r h2 -> (R.l r) <= (R.r r))) *)
(* let monotonic_id x y = compose2 id id x y *)


type low 'a = x:(double 'a){R.l x = R.r x}
type high 'a = double 'a

val one : double int
let one = twice 1

val pair_map2 : ('a -> 'b -> Tot 'c) -> (double 'a) -> (double 'b) -> Tot (double 'c)
let pair_map2 f (R x1 x2) (R y1 y2) = R (f x1 y1) (f x2 y2)

let plus = pair_map2 (fun x y -> x + y)

val test_info : (high int * low int) -> Tot (high int * low int)
(* This one fails as expected *)
(* val test_info : (high int * low int) -> (low int * low int) *)
let test_info (x,y) = ((plus x y), (plus y one))

let minus  = pair_map2 (fun x y -> x - y)

val test_minus : high int -> Tot (low int)
let test_minus z = minus z z

type monotonic = x:double int -> Tot (y:(double int){R.l x <= R.r x ==> R.l y <= R.r y})

type k_sensitive (d:(int -> int -> Tot int)) (k:int) =
   x:double int -> Tot (y:(double int){d (R.l y) (R.r y) <= k * (d (R.l x) (R.r x))})

val foo : k:int -> double int -> Tot (double int)
let foo k x = pair_map2 (fun k x -> k * x) (twice k) x

val foo_monotonic : k:int{k>=0} -> Tot monotonic
let foo_monotonic k = (fun x -> pair_map2 (fun k x -> k * x) (twice k) x)

val dist : int -> int -> Tot int
let dist x1 x2 = let m = x1 - x2 in
              if m >= 0 then m else -m

val foo_k_sensitive : k:int{k>0} -> Tot (k_sensitive dist k)
let foo_k_sensitive k = (fun x -> pair_map2 (fun k x -> k * x) (twice k) x)


(* This does not work if I η-expand [noleak] in the body of noleak_ok *)
let noleak (x,b) = if b then x := 1 else x := 1
val noleak_ok: x1:ref int
               -> x2:ref int
               -> b1:bool
               -> b2:bool
               -> ST2 (rel unit unit)
                             (requires (fun h -> True))
                             (ensures (fun h1 r h2 -> ((x1 = x2) /\ (R.l h1 = R.r h1)) ==> (R.l h2 = R.r h2)))
let noleak_ok x1 x2 b1 b2 = compose2 noleak noleak (x1,b1) (x2,b2)

(* Simple recursive function:
   The proof works by proving a pure specification for the imperative functions
   and by proving the equality of those specifiactions *)

(* Pure specifications *)
val gauss : nat -> Tot nat
let gauss x = (x * x + x) / 2

val gauss_rec : nat -> nat -> Tot nat
let rec gauss_rec x a = if x = 0 then a else gauss_rec (x - 1) (a + x)

(* Proof of the equality for the pure specifiaction *)
val gauss_lemma : x:nat -> a:nat -> Lemma
                        (requires True)
                        (ensures (gauss x + a = gauss_rec x a))
                        [SMTPat (gauss_rec x a)]
let rec gauss_lemma x a = if x = 0 then () else gauss_lemma (x-1) (a+x)

val equiv_gauss: x : nat
                 -> ST2 (rel nat nat)
                    (requires (fun _ -> True))
                    (ensures (fun _ p _ -> R.l p = R.r p))
let equiv_gauss x = compose2 (fun x -> gauss_rec x 0) (fun x -> gauss x) x x

(* We prove, that the imperative functions fulfill the specifiaction *)
val gauss_imp : x:ref nat -> ST nat
                    (requires (fun h -> True))
                    (ensures  (fun h0 r h1 -> r = gauss (sel h0 x)))
let gauss_imp x = (!x*!x + !x)/2

val gauss_imp_rec : p:((ref nat) * (ref nat)) -> ST nat
                    (requires (fun h -> fst p <> snd p))
                    (ensures  (fun h0 r h1 ->
                      r = gauss_rec ((sel h0) (fst p)) ((sel h0) (snd p)) /\
                      sel h1 (snd p) = r ))
let rec gauss_imp_rec (x, a) = if !x = 0 then !a
                           else (a := !a + !x; x := !x-1; gauss_imp_rec (x, a))

(* We can conclude the equality for the imperative functions *)
val equiv_gauss_imp: x:ref nat
                 -> a:ref nat
                 -> ST2 (rel nat nat)
                    (requires (fun h2 -> a <> x /\
                                        sel (R.l h2) x = sel (R.r h2) x /\
                                        sel (R.l h2) a = 0 ))
                    (ensures (fun _ p h2 -> R.l p = R.r p))
let equiv_gauss_imp x a = compose2 gauss_imp_rec gauss_imp (x,a) x
