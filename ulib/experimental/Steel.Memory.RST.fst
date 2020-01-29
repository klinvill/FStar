module Steel.Memory.RST

open Steel.Memory
open Steel.Actions
open Steel.Memory.Tactics
open LowStar.Permissions
module U32 = FStar.UInt32

new_effect GST = STATE_h mem

let gst_pre = st_pre_h mem
let gst_post' (a:Type) (pre:Type) = st_post_h' mem a pre
let gst_post (a:Type) = st_post_h mem a
let gst_wp (a:Type) = st_wp_h mem a

unfold let lift_div_gst (a:Type) (wp:pure_wp a) (p:gst_post a) (h:mem) = wp (fun a -> p a h)
sub_effect DIV ~> GST = lift_div_gst

effect ST (a:Type) (pre:gst_pre) (post: (m0:mem -> Tot (gst_post' a (pre m0)))) =
  GST a
    (fun (p:gst_post a) (h:mem) -> pre h /\ (forall a h1. (pre h /\ post h a h1) ==> p a h1))

/// Attribute for normalization
let __reduce__ = ()

(** TODO: Add a value_depends_only_on fp predicate. With this predicate,
    we should be able to conclude that any predicate defined using only the views
    is on fp_prop fp **)
type view' (a:Type) (fp:hprop) = (m:hheap fp) -> GTot a

let view_depends_only_on (#a:Type) (#fp: hprop) (f:view' a fp) =
  (forall (h0:hheap fp) (h1:heap{disjoint h0 h1}). (
    (**) intro_emp h1;
    (**) intro_star fp emp h0 h1;
    (**) emp_unit fp;
    f h0 == f (join h0 h1)))

let view (a:Type) (fp:hprop) = f:view' a fp{view_depends_only_on f}

(** An extension of hprops to include a view.
    Note that the type of the view is not related to the fprop, and is completely up to the user.
    For hprops for which we cannot defined a view, we thus could use unit.
    TODO: This should have a better name. hprop_with_view?
    **)
[@(__reduce__) erasable]
noeq
type viewable' = {
    t:Type0;
    fp:hprop;
    sel:view t fp }

(** Redefine an inductive for Star on top of hprops/viewables. This will allow us
    to normalize by induction on the datatype **)
[@(__reduce__) erasable]
noeq type viewable =
   | VUnit: viewable' -> viewable
   | VStar: viewable -> viewable -> viewable

(** TODO: Could we go to a "flat" representation of tuples from t_of? **)
[@__reduce__]
let rec t_of (v:viewable) = match v with
  | VUnit v -> v.t
  | VStar v1 v2 -> (t_of v1 * t_of v2)

[@__reduce__]
let rec fp_of (v:viewable) : GTot hprop = match v with
  | VUnit v -> v.fp
  | VStar v1 v2 -> (fp_of v1 `star` fp_of v2)

[@__reduce__]
let rec sel_of (v:viewable) (h:hheap (fp_of v)) : GTot (t_of v) = match v with
  | VUnit v -> v.sel h
  | VStar v1 v2 ->
    affine_star (fp_of v1) (fp_of v2) h;
    (sel_of v1 h, sel_of v2 h)

// Irreducible for now because of goals disappearing in tactics again...
// This should just be hidden behind a val in another module,
// while exposing all the necessary lemmas
irreducible
let equiv (r1 r2:viewable) : (p:prop{p <==> equiv (fp_of r1) (fp_of r2)})
  = equiv (fp_of r1) (fp_of r2) /\ True

let can_be_split_into (outer inner delta:viewable) : prop =
  (VStar inner delta) `equiv` outer

(** A shortcut for the normalization. We need to reduce all our recursive functions **)
unfold
let normal (#a:Type) (x:a) =
  let open FStar.Algebra.CommMonoid.Equiv in
  norm [delta_attr [`%__reduce__];
       delta;
        delta_only [
          `%__proj__CM__item__mult;
          `%__proj__Mktuple2__item___1; `%__proj__Mktuple2__item___2;
          `%fst; `%snd];
        primops; iota; zeta] x


/// Selectors for hprops
/// AF: Will we need to limit this to r0:viewable{VUnit? r0 /\ is_subresource} ? This might
/// allow an easier, reduceable definition for mk_rmem
let rmem (r: viewable) : Type =
   (r0:viewable{exists delta. can_be_split_into r r0 delta}) -> GTot (normal (t_of r0))

/// Reimplementing tactics for framing.
/// AF: This should be moved to a separate module once hprops with views are stable and
/// moved to Steel.Memory

(** A more convenient notation for VStar **)
[@__reduce__]
unfold
let (<*>) = VStar

module CME = FStar.Algebra.CommMonoid.Equiv
module T = FStar.Tactics
module TCE = FStar.Tactics.CanonCommMonoidSimple.Equiv

let equiv_refl (x:viewable) : Lemma (equiv x x) = ()

let equiv_sym (x y:viewable) : Lemma
  (requires equiv x y)
  (ensures equiv y x)
  = ()

let equiv_trans (x y z:viewable) : Lemma
  (requires equiv x y /\ equiv y z)
  (ensures equiv x z)
  = ()

inline_for_extraction noextract
let req : CME.equiv viewable =
  CME.EQ equiv
         equiv_refl
         equiv_sym
         equiv_trans

let vemp' : viewable' = {
  t = unit;
  fp = emp;
  sel = fun _ -> () }

[@__reduce__]
let vemp : viewable = VUnit vemp'

let cm_identity (x:viewable) : Lemma ((vemp <*> x) `equiv` x)
  = star_commutative emp (fp_of x);
    emp_unit (fp_of x)

let star_commutative (p1 p2:viewable)
  : Lemma ((p1 <*> p2) `equiv` (p2 <*> p1))
  = star_commutative (fp_of p1) (fp_of p2)

let star_associative (p1 p2 p3:viewable)
  : Lemma ((p1 <*> p2 <*> p3)
           `equiv`
           (p1 <*> (p2 <*> p3)))
  = star_associative (fp_of p1) (fp_of p2) (fp_of p3)

let star_congruence (p1 p2 p3 p4:viewable)
  : Lemma (requires p1 `equiv` p3 /\ p2 `equiv` p4)
          (ensures (p1 <*> p2) `equiv` (p3 <*> p4))
  = star_congruence (fp_of p1) (fp_of p2) (fp_of p3) (fp_of p4)

[@__reduce__]
inline_for_extraction noextract
let rm : CME.cm viewable req =
  CME.CM vemp
         (<*>)
         cm_identity
         star_associative
         star_commutative
         star_congruence

let canon () : T.Tac unit = TCE.canon_monoid (`req) (`rm)

let squash_and p q (x:squash (p /\ q)) : (p /\ q) =
  let x : squash (p `c_and` q) = FStar.Squash.join_squash x in
  x

let can_be_split_into_star (res1 res2 res3:viewable)
  : Lemma
    (requires ((res2 <*> res3) `equiv` res1))
    (ensures  (can_be_split_into res1 res2 res3))
  = ()

inline_for_extraction noextract let resolve_frame () : T.Tac unit =
  T.refine_intro();
  T.flip();
  T.apply_lemma (`T.unfold_with_tactic);
  T.split();
  T.apply_lemma (`can_be_split_into_star);
  T.flip();
  T.dump "pre canon";
  canon();
  T.trivial()

inline_for_extraction noextract let reprove_frame () : T.Tac unit =
  T.apply (`squash_and);
  T.split();
  T.apply_lemma (`can_be_split_into_star);
  canon();
  T.trivial()


/// The function creating a selector out of a resource
/// Interestingly, we do not seem to require any more info about this function:
/// A previous version with an assume val an no other postcondition that the type rmem r
/// was sufficient for this file to go through
[@__reduce__]
let mk_rmem
  (r: viewable)
  (h: heap) :
  Pure (rmem r)
    (requires interp (fp_of r) h)
    (ensures fun _ -> True)
  =
  fun (r0:viewable{exists delta. can_be_split_into r r0 delta}) ->
    Classical.forall_intro_3 affine_star;
    sel_of r0 h

effect Steel
  (a: Type)
  (res0: viewable)
  (res1: a -> GTot viewable)
  (pre: (rmem res0) -> GTot prop)
  (post: (rmem res0) -> (x:a) -> (rmem (res1 x)) -> GTot prop)
= ST
  a
  (fun h0 ->
    interp (fp_of res0) (heap_of_mem h0) /\
    normal (pre (mk_rmem res0 (heap_of_mem h0))))
  (fun h0 x h1 ->
    interp (fp_of res0) (heap_of_mem h0) /\
    normal (pre (mk_rmem res0 (heap_of_mem h0))) /\
    interp (fp_of (res1 x)) (heap_of_mem h1) /\
    normal (post (mk_rmem res0 (heap_of_mem h0))
                 x
                 (mk_rmem (res1 x) (heap_of_mem h1)))
  )

/// Going back to the tuples representation here for convenience,
/// but it's only exposed to the SMT solver as a postcondition of frame and get
[@__reduce__]
let rec expand_delta
  (#outer0:viewable) (h0:rmem outer0)
  (#outer1:viewable) (h1:rmem outer1)
  (delta:viewable)
  (inner0:viewable{can_be_split_into outer0 inner0 delta})
  (inner1:viewable{can_be_split_into outer1 inner1 delta})
  : GTot prop
  = match delta with
    | VStar v1 v2 ->
      Classical.forall_intro_3 (fun x y -> Classical.move_requires (equiv_trans x y));
      calc (equiv) {
        inner0 <*> v2 <*> v1;
        (equiv) { star_associative inner0 v2 v1 }
        inner0 <*> (v2 <*> v1);
        (equiv) { star_commutative v2 v1;
                  equiv_refl inner0;
                  star_congruence inner0 (v2 <*> v1) inner0 (v1 <*> v2) }
        inner0 <*> (v1 <*> v2);
      };
      calc (equiv) {
        inner0 <*> v1 <*> v2;
        (equiv) { star_associative inner0 v1 v2 }
        inner0 <*> delta;
      };
      calc (equiv) {
        inner1 <*> v2 <*> v1;
        (equiv) { star_associative inner1 v2 v1 }
        inner1 <*> (v2 <*> v1);
        (equiv) { star_commutative v2 v1;
                  equiv_refl inner1;
                  star_congruence inner1 (v2 <*> v1) inner1 (v1 <*> v2) }
        inner1 <*> (v1 <*> v2);
      };
      calc (equiv) {
        inner1 <*> v1 <*> v2;
        (equiv) { star_associative inner1 v1 v2 }
        inner1 <*> delta;
      };
      expand_delta h0 h1 v1 (inner0 <*> v2) (inner1 <*> v2) /\
      expand_delta h0 h1 v2 (inner0 <*> v1) (inner1 <*> v1)
    | v ->
      star_commutative delta inner0;
      equiv_trans (delta <*> inner0)  (inner0 <*> delta) outer0;
      star_commutative delta inner1;
      equiv_trans (delta <*> inner1)  (inner1 <*> delta) outer1;
      h0 v == h1 v

[@__reduce__]
let rec expand_delta_heap
  (#outer:viewable) (h0:hheap (fp_of outer)) (s0:rmem outer)
  (delta:viewable)
  (inner:viewable{can_be_split_into outer inner delta})
  : GTot prop
  = match delta with
    | VStar v1 v2 ->
      Classical.forall_intro_3 (fun x y -> Classical.move_requires (equiv_trans x y));
      calc (equiv) {
        inner <*> v2 <*> v1;
        (equiv) { star_associative inner v2 v1 }
        inner <*> (v2 <*> v1);
        (equiv) { star_commutative v2 v1;
                  equiv_refl inner;
                  star_congruence inner (v2 <*> v1) inner (v1 <*> v2) }
        inner <*> (v1 <*> v2);
      };
      calc (equiv) {
        inner <*> v1 <*> v2;
        (equiv) { star_associative inner v1 v2 }
        inner <*> delta;
      };

      expand_delta_heap h0 s0 v1 (inner <*> v2) /\
      expand_delta_heap h0 s0 v2 (inner <*> v1)
    | VUnit v ->
      star_commutative delta inner;
      equiv_trans (delta <*> inner)  (inner <*> delta) outer;
      affine_star v.fp (fp_of inner) h0;
      s0 (VUnit v) == v.sel h0


/// AF: get_mem and put_mem should only be used in trusted, core libraries (to lift actions
/// to functions with the Steel effect)
/// For proof purposes (i.e. the current HS.get()), we should expose a get returning selectors instead
(** We underspecify get: It returns a heap about which we only know that
    the resource invariant is satisfied, and that the view of the resouce
    corresponds to the ones we would compute from this heap **)
assume val get_mem (r:viewable)
  :Steel (hmem (fp_of r)) (r) (fun _ -> r)
             (requires (fun m -> True))
             (ensures (fun h0 x h1 ->
               (**) cm_identity r;
               (**) star_commutative r vemp;
               (**) affine_star (fp_of r) (locks_invariant x) (heap_of_mem x);
               // Instead of equality on selectors, we expose equalities on applications
               // of the selector to all subresources
               normal (expand_delta h0 h1 r vemp vemp) /\
               h0 r == sel_of r (heap_of_mem x)))

assume val put_mem (r_init r_out:viewable) (m:hmem (fp_of r_out))
  :Steel unit (r_init) (fun _ -> r_out)
             (requires fun m -> True)
             (ensures (fun _ _ m1 ->
               (**) cm_identity r_out;
               (**) star_commutative r_out vemp;
               (**) affine_star (fp_of r_out) (locks_invariant m) (heap_of_mem m);
               // Again, we expose equalities on applications of selectors.
               // This allows a better normalization instead of an equality on functions
               normal (expand_delta_heap #r_out (heap_of_mem m) m1 r_out vemp)))

/// This primitive should be used for proof purposes only, in a similar manner as HS.get
/// It returns the selector for the current resource in the context. The selector should probably
/// be erased
assume val get (r:viewable)
  : Steel (rmem r) r (fun _ -> r)
          (requires fun _ -> True)
          (ensures fun m0 v m1 -> m0 == m1 /\ v == m1)

(*
let interp_perm_to_ptr (#a:Type) (p:permission) (r:ref a) (h:heap)
  : Lemma (requires interp (ptr_perm r p) h)
          (ensures interp (ptr r) h)
  = let lem (v:a) (h:heap) : Lemma
   (requires interp (pts_to r p v) h)
   (ensures interp (ptr r) h)
   = intro_exists v (pts_to r p) h;
     intro_exists p (ptr_perm r) h
   in Classical.forall_intro (Classical.move_requires (fun v -> lem v h));
   elim_exists (pts_to r p) (ptr r) h

let interp_pts_to_perm (#a:Type) (p:permission) (r:ref a) (v:a) (h:heap)
  : Lemma (requires interp (pts_to r p v) h)
          (ensures interp (ptr_perm r p) h)
  = let lem (v:a) (h:heap) : Lemma
     (requires interp (pts_to r p v) h)
     (ensures interp (ptr_perm r p) h)
     = intro_exists v (pts_to r p) h
     in Classical.forall_intro (Classical.move_requires (fun v -> lem v h))

let pts_to_sel (#a:Type) (p:permission) (r:ref a) (v:a) (h:heap)
  : Lemma (requires interp (pts_to r p v) h)
          (ensures interp (ptr r) h /\ sel r h == v)
  = interp_pts_to_perm p r v h; interp_perm_to_ptr p r h;
    sel_lemma r p h;
    pts_to_injective r p v (sel r h) h
*)

let has_length_1 (#a:Type) (r:array_ref a) (h:heap) : prop = U32.v (length r) == 1

let fptr (#a:Type) (r:array_ref a) : hprop =
  refine (array_perm r full_permission) (has_length_1 r)

let fsel (#a:Type) (r:array_ref a) (h:hheap (fptr r)) : a =
  refine_equiv (array_perm r full_permission) (has_length_1 r) h;
//  interp_perm_to_ptr full_permission r h;
  assume (interp (array r) h);
  Seq.index (as_seq r h) 0

let fsel_is_view (#a:Type) (r:array_ref a) (h0:hheap (fptr r)) (h1:heap{disjoint h0 h1})
  : Lemma
  (ensures
    interp (fptr r) (join h0 h1) /\
    fsel r h0 == fsel r (join h0 h1))
  = admit()
  (*
    (**) intro_emp h1;
    (**) intro_star (fptr r) emp h0 h1;
    (**) emp_unit (fptr r);
    interp_perm_to_ptr full_permission r h0;
    sel_split_lemma r h0 h1
    *)

let fsel_view (#a:Type) (r:array_ref a) : view a (fptr r) =
    Classical.forall_intro_2 (fsel_is_view r);
    fsel r

(** The actual hprop with view for a pointer. Its view has the same type as the pointer **)
let vptr' (#a:Type) (r:array_ref a) : GTot viewable' =
  ({ t = a;
    fp = fptr r;
    sel = fsel_view r})

[@__reduce__]
let vptr (#a:Type) (r:array_ref a) : GTot viewable = VUnit (vptr' r)

#push-options "--no_tactics"

/// AF: We need the memory to be the last argument. If not, we finish with an implicit argument,
/// which F* expects us to provide. If we do not provide it, the type of an application seems to
/// be the type of the partial application
/// TODO: This should also be renamed to something better during cleanup of this module
/// TODO: We probably can take the pointer directly instead of the viewable
[@__reduce__]
let view_sel
  (#outer:viewable)
  (inner:viewable)
  (#[resolve_frame()]
    delta:viewable{
      FStar.Tactics.with_tactic
      reprove_frame
      (can_be_split_into outer inner delta /\ True)})
  (h:rmem outer)
 : GTot (normal (t_of inner))
  = T.by_tactic_seman reprove_frame (can_be_split_into outer inner delta /\ True);
    h inner

#pop-options

val fread (#a:Type) (r:array_ref a) : Steel a
  (vptr r) (fun _ -> vptr r)
  (requires fun _ -> True)
  (ensures fun h0 v h1 ->
    view_sel (vptr r) h0 == view_sel (vptr r) h1 /\ v == view_sel (vptr r) h1)

let fread #a r = admit()
  // let m = get_mem (vptr r) in
  // (**) affine_star (fp_of (vptr r)) (locks_invariant m) (heap_of_mem m);
  // fsel r (heap_of_mem m)

val fupd (#a:Type) (r:ref a) (v:a) : Steel unit
  (fptr r) (fun _ -> fptr r)
  (requires fun _ -> True)
  (ensures fun _ _ m1 -> view_sel (vptr r) m1 == v)

let fupd #a r v = admit()
  // let m = get_mem (vptr r) in
  // let (| _, m' |) = upd r v m in
  // (**) let h1, h2 = split_mem (pts_to r full_permission v) (locks_invariant m') (heap_of_mem m') in
  // (**) interp_pts_to_perm full_permission r v h1;
  // (**) intro_star (fptr r) (locks_invariant m') h1 h2;
  // (**) affine_star (fp_of (vptr r)) (locks_invariant m') (heap_of_mem m');
  // (**) affine_star (pts_to r full_permission v) (locks_invariant m') (heap_of_mem m');
  // (**) pts_to_sel full_permission r v (heap_of_mem m');
  // put_mem (vptr r) (vptr r) m'

let lemma_sub_subresource (outer inner r:viewable)
  (delta:viewable{can_be_split_into outer inner delta})
  (delta':viewable)
  : Lemma
      (requires can_be_split_into inner r delta')
      (ensures can_be_split_into outer r (delta' <*> delta))
  = Classical.forall_intro_3 (fun x y -> Classical.move_requires (equiv_trans x y));
    Classical.forall_intro_2 (fun x -> Classical.move_requires (equiv_sym x));
    calc (equiv) {
      r <*> (delta' <*> delta);
      (equiv) { star_associative r delta' delta }
      (r <*> delta') <*> delta;
      (equiv) { equiv_refl delta; star_congruence inner delta (r <*> delta') delta }
      inner <*> delta;
      (equiv) {  }
      outer;
    }

[@__reduce__]
let focus_rmem (#outer: viewable) (h: rmem outer)
  (inner: viewable)
  (delta:viewable{can_be_split_into outer inner delta})
  : Tot (h':rmem inner)
  = (fun (r:viewable{exists delta'. can_be_split_into inner r delta'}) ->
      Classical.forall_intro (Classical.move_requires (lemma_sub_subresource outer inner r delta));
      h r)

#push-options "--z3rlimit 20"


#push-options "--no_tactics"

assume
val frame
  (outer:viewable)
  (#inner0:viewable)
  (#a:Type)
  (#inner1:a -> viewable)
  (#[resolve_frame()]
    delta:viewable{
      FStar.Tactics.with_tactic
      reprove_frame
      (can_be_split_into outer inner0 delta /\ True)})
  (#pre:rmem inner0 -> prop)
  (#post:rmem inner0 -> (x:a) -> rmem (inner1 x) -> prop)
  ($f:unit -> Steel a inner0 inner1 pre post)
  : Steel a
          outer
          (* Observe that we do not need to use tactics for the postresource here. *)
          (fun v -> (inner1 v) <*> delta)
          (* We should satisfy the precondition of the framed function, using only the views
              of inner0 *)
          (fun v ->
            (**) T.by_tactic_seman reprove_frame (can_be_split_into outer inner0 delta /\ True);
            normal (pre (focus_rmem v inner0 delta)))
          (fun h0 x h1 ->
            (**) T.by_tactic_seman reprove_frame (can_be_split_into outer inner0 delta /\ True);
            (**) equiv_refl (inner1 x <*> delta);
            normal (post (focus_rmem h0 inner0 delta) x (focus_rmem h1 (inner1 x) delta)) /\
            normal (expand_delta h0 h1 delta inner0 (inner1 x))
          )

#pop-options

#reset-options "--max_fuel 0 --max_ifuel 0"

(** A few tests of framing and normalization. An interesting observation is that we
    do not need fuel to obtain egalities on "atomic" resources inside delta. **)

val test1 (#a:Type) (r1 r2:ref a) : Steel a
  (vptr r1 <*> vptr r2)
  (fun _ -> vptr r1 <*> vptr r2)
  (fun _ -> True)
  (fun olds v news ->
     view_sel (vptr r1) news == v /\
     view_sel (vptr r2) olds == view_sel (vptr r2) news
     )

let test1 #a r1 r2 =
  let v = frame (vptr r1 <*> vptr r2)
        (fun () -> fread r1) in
// For debug purposes, we can check the SMT context and state of normalization
// by uncommenting the following assertion
  assert (True) by (T.dump "test1");
  v

val test2 (#a:Type) (r1 r2 r3:ref a) : Steel a
  (vptr r1 <*> vptr r2 <*> vptr r3)
  (fun _ -> vptr r1 <*> (vptr r2 <*> vptr r3))
  (fun _ -> True)
  (fun olds x news ->
    view_sel (vptr r1) news == x /\
    view_sel (vptr r2) news == view_sel (vptr r2) olds /\
    view_sel (vptr r3) news == view_sel (vptr r3) olds)

let test2 #a r1 r2 r3 =
  let v = frame (vptr r1 <*> vptr r2 <*> vptr r3)
        (fun () -> fread r1) in
  v

val test3 (#a:Type) (r1 r2 r3 r4:ref a) : Steel a
  (vptr r1 <*> vptr r2 <*> vptr r3 <*> vptr r4)
  // The ordering is a bit annoying… We should try to have a final "rewriting" pass through
  // normalization once we have the frame inference tactic
  (fun _ -> vptr r3 <*> (vptr r1 <*> (vptr r2 <*> vptr r4)))
  (fun _ -> True)
  (fun olds x news ->
    view_sel (vptr r3) news == x /\
    view_sel (vptr r1) news == view_sel (vptr r1) olds /\
    view_sel (vptr r2) news == view_sel (vptr r2) olds /\
    view_sel (vptr r4) news == view_sel (vptr r4) olds)

let test3 #a r1 r2 r3 r4 =
  frame (vptr r1 <*> vptr r2 <*> vptr r3 <*> vptr r4)
        (fun () -> fread r3)

val test_upd1 (#a:Type) (r1 r2:ref a) (v:a) : Steel unit
  (vptr r1 <*> vptr r2)
  (fun _ -> vptr r1 <*> vptr r2)
  (fun _ -> True)
  (fun olds _ news ->
     view_sel (vptr r1) news == v /\
     view_sel (vptr r2) olds == view_sel (vptr r2) news
     )

let test_upd1 #a r1 r2 v =
  frame (vptr r1 <*> vptr r2)
        (fun () -> fupd r1 v)

val test_upd2 (#a:Type) (r1 r2 r3 r4:ref a) (v:a) : Steel unit
  (vptr r1 <*> vptr r2 <*> vptr r3 <*> vptr r4)
  // The ordering is a bit annoying… We should try to have a final "rewriting" pass through
  // normalization once we have the frame inference tactic
  (fun _ -> vptr r3 <*> (vptr r1 <*> (vptr r2 <*> vptr r4)))
  (fun _ -> True)
  (fun olds _ news ->
    view_sel (vptr r3) news == v /\
    view_sel (vptr r1) news == view_sel (vptr r1) olds /\
    view_sel (vptr r2) news == view_sel (vptr r2) olds /\
    view_sel (vptr r4) news == view_sel (vptr r4) olds)

let test_upd2 #a r1 r2 r3 r4 v =
  frame (vptr r1 <*> vptr r2 <*> vptr r3 <*> vptr r4)
        (fun () -> fupd r3 v)