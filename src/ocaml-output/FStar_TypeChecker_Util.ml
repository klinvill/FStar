open Prims
type lcomp_with_binder =
  (FStar_Syntax_Syntax.bv Prims.option * FStar_Syntax_Syntax.lcomp)
let report :
  FStar_TypeChecker_Env.env -> Prims.string Prims.list -> Prims.unit =
  fun env  ->
    fun errs  ->
      let uu____12 = FStar_TypeChecker_Env.get_range env  in
      let uu____13 = FStar_TypeChecker_Err.failed_to_prove_specification errs
         in
      FStar_Errors.report uu____12 uu____13
  
let is_type : FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____17 =
      let uu____18 = FStar_Syntax_Subst.compress t  in
      uu____18.FStar_Syntax_Syntax.n  in
    match uu____17 with
    | FStar_Syntax_Syntax.Tm_type uu____21 -> true
    | uu____22 -> false
  
let t_binders :
  FStar_TypeChecker_Env.env ->
    (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) Prims.list
  =
  fun env  ->
    let uu____29 = FStar_TypeChecker_Env.all_binders env  in
    FStar_All.pipe_right uu____29
      (FStar_List.filter
         (fun uu____35  ->
            match uu____35 with
            | (x,uu____39) -> is_type x.FStar_Syntax_Syntax.sort))
  
let new_uvar_aux :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.typ ->
      (FStar_Syntax_Syntax.typ * FStar_Syntax_Syntax.typ)
  =
  fun env  ->
    fun k  ->
      let bs =
        let uu____49 =
          (FStar_Options.full_context_dependency ()) ||
            (let uu____50 = FStar_TypeChecker_Env.current_module env  in
             FStar_Ident.lid_equals FStar_Syntax_Const.prims_lid uu____50)
           in
        match uu____49 with
        | true  -> FStar_TypeChecker_Env.all_binders env
        | uu____51 -> t_binders env  in
      let uu____52 = FStar_TypeChecker_Env.get_range env  in
      FStar_TypeChecker_Rel.new_uvar uu____52 bs k
  
let new_uvar :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.typ
  =
  fun env  ->
    fun k  -> let uu____59 = new_uvar_aux env k  in Prims.fst uu____59
  
let as_uvar : FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.uvar =
  fun uu___91_64  ->
    match uu___91_64 with
    | { FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_uvar (uv,uu____66);
        FStar_Syntax_Syntax.tk = uu____67;
        FStar_Syntax_Syntax.pos = uu____68;
        FStar_Syntax_Syntax.vars = uu____69;_} -> uv
    | uu____84 -> failwith "Impossible"
  
let new_implicit_var :
  Prims.string ->
    FStar_Range.range ->
      FStar_TypeChecker_Env.env ->
        FStar_Syntax_Syntax.typ ->
          (FStar_Syntax_Syntax.term * (FStar_Syntax_Syntax.uvar *
            FStar_Range.range) Prims.list * FStar_TypeChecker_Env.guard_t)
  =
  fun reason  ->
    fun r  ->
      fun env  ->
        fun k  ->
          let uu____103 =
            FStar_Syntax_Util.destruct k FStar_Syntax_Const.range_of_lid  in
          match uu____103 with
          | Some (uu____116::(tm,uu____118)::[]) ->
              let t =
                (FStar_Syntax_Syntax.mk
                   (FStar_Syntax_Syntax.Tm_constant
                      (FStar_Const.Const_range (tm.FStar_Syntax_Syntax.pos))))
                  None tm.FStar_Syntax_Syntax.pos
                 in
              (t, [], FStar_TypeChecker_Rel.trivial_guard)
          | uu____162 ->
              let uu____169 = new_uvar_aux env k  in
              (match uu____169 with
               | (t,u) ->
                   let g =
                     let uu___111_181 = FStar_TypeChecker_Rel.trivial_guard
                        in
                     let uu____182 =
                       let uu____190 =
                         let uu____197 = as_uvar u  in
                         (reason, env, uu____197, t, k, r)  in
                       [uu____190]  in
                     {
                       FStar_TypeChecker_Env.guard_f =
                         (uu___111_181.FStar_TypeChecker_Env.guard_f);
                       FStar_TypeChecker_Env.deferred =
                         (uu___111_181.FStar_TypeChecker_Env.deferred);
                       FStar_TypeChecker_Env.univ_ineqs =
                         (uu___111_181.FStar_TypeChecker_Env.univ_ineqs);
                       FStar_TypeChecker_Env.implicits = uu____182
                     }  in
                   let uu____210 =
                     let uu____214 =
                       let uu____217 = as_uvar u  in (uu____217, r)  in
                     [uu____214]  in
                   (t, uu____210, g))
  
let check_uvars : FStar_Range.range -> FStar_Syntax_Syntax.typ -> Prims.unit
  =
  fun r  ->
    fun t  ->
      let uvs = FStar_Syntax_Free.uvars t  in
      let uu____235 =
        let uu____236 = FStar_Util.set_is_empty uvs  in
        Prims.op_Negation uu____236  in
      match uu____235 with
      | true  ->
          let us =
            let uu____240 =
              let uu____242 = FStar_Util.set_elements uvs  in
              FStar_List.map
                (fun uu____258  ->
                   match uu____258 with
                   | (x,uu____266) -> FStar_Syntax_Print.uvar_to_string x)
                uu____242
               in
            FStar_All.pipe_right uu____240 (FStar_String.concat ", ")  in
          (FStar_Options.push ();
           FStar_Options.set_option "hide_uvar_nums"
             (FStar_Options.Bool false);
           FStar_Options.set_option "print_implicits"
             (FStar_Options.Bool true);
           (let uu____283 =
              let uu____284 = FStar_Syntax_Print.term_to_string t  in
              FStar_Util.format2
                "Unconstrained unification variables %s in type signature %s; please add an annotation"
                us uu____284
               in
            FStar_Errors.report r uu____283);
           FStar_Options.pop ())
      | uu____285 -> ()
  
let force_sort' :
  (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
    FStar_Syntax_Syntax.syntax -> FStar_Syntax_Syntax.term'
  =
  fun s  ->
    let uu____293 = FStar_ST.read s.FStar_Syntax_Syntax.tk  in
    match uu____293 with
    | None  ->
        let uu____298 =
          let uu____299 =
            FStar_Range.string_of_range s.FStar_Syntax_Syntax.pos  in
          let uu____300 = FStar_Syntax_Print.term_to_string s  in
          FStar_Util.format2 "(%s) Impossible: Forced tk not present on %s"
            uu____299 uu____300
           in
        failwith uu____298
    | Some tk -> tk
  
let force_sort s =
  let uu____315 =
    let uu____318 = force_sort' s  in FStar_Syntax_Syntax.mk uu____318  in
  uu____315 None s.FStar_Syntax_Syntax.pos 
let extract_let_rec_annotation :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.letbinding ->
      (FStar_Syntax_Syntax.univ_name Prims.list * FStar_Syntax_Syntax.typ *
        Prims.bool)
  =
  fun env  ->
    fun uu____335  ->
      match uu____335 with
      | { FStar_Syntax_Syntax.lbname = lbname;
          FStar_Syntax_Syntax.lbunivs = univ_vars;
          FStar_Syntax_Syntax.lbtyp = t;
          FStar_Syntax_Syntax.lbeff = uu____342;
          FStar_Syntax_Syntax.lbdef = e;_} ->
          let rng = FStar_Syntax_Syntax.range_of_lbname lbname  in
          let t = FStar_Syntax_Subst.compress t  in
          (match t.FStar_Syntax_Syntax.n with
           | FStar_Syntax_Syntax.Tm_unknown  ->
               ((match univ_vars <> [] with
                 | true  ->
                     failwith
                       "Impossible: non-empty universe variables but the type is unknown"
                 | uu____363 -> ());
                (let r = FStar_TypeChecker_Env.get_range env  in
                 let mk_binder scope a =
                   let uu____374 =
                     let uu____375 =
                       FStar_Syntax_Subst.compress a.FStar_Syntax_Syntax.sort
                        in
                     uu____375.FStar_Syntax_Syntax.n  in
                   match uu____374 with
                   | FStar_Syntax_Syntax.Tm_unknown  ->
                       let uu____380 = FStar_Syntax_Util.type_u ()  in
                       (match uu____380 with
                        | (k,uu____386) ->
                            let t =
                              let uu____388 =
                                FStar_TypeChecker_Rel.new_uvar
                                  e.FStar_Syntax_Syntax.pos scope k
                                 in
                              FStar_All.pipe_right uu____388 Prims.fst  in
                            ((let uu___112_393 = a  in
                              {
                                FStar_Syntax_Syntax.ppname =
                                  (uu___112_393.FStar_Syntax_Syntax.ppname);
                                FStar_Syntax_Syntax.index =
                                  (uu___112_393.FStar_Syntax_Syntax.index);
                                FStar_Syntax_Syntax.sort = t
                              }), false))
                   | uu____394 -> (a, true)  in
                 let rec aux must_check_ty vars e =
                   let e = FStar_Syntax_Subst.compress e  in
                   match e.FStar_Syntax_Syntax.n with
                   | FStar_Syntax_Syntax.Tm_meta (e,uu____419) ->
                       aux must_check_ty vars e
                   | FStar_Syntax_Syntax.Tm_ascribed (e,t,uu____426) ->
                       (t, true)
                   | FStar_Syntax_Syntax.Tm_abs (bs,body,uu____453) ->
                       let uu____476 =
                         FStar_All.pipe_right bs
                           (FStar_List.fold_left
                              (fun uu____500  ->
                                 fun uu____501  ->
                                   match (uu____500, uu____501) with
                                   | ((scope,bs,must_check_ty),(a,imp)) ->
                                       let uu____543 =
                                         match must_check_ty with
                                         | true  -> (a, true)
                                         | uu____548 -> mk_binder scope a  in
                                       (match uu____543 with
                                        | (tb,must_check_ty) ->
                                            let b = (tb, imp)  in
                                            let bs = FStar_List.append bs [b]
                                               in
                                            let scope =
                                              FStar_List.append scope [b]  in
                                            (scope, bs, must_check_ty)))
                              (vars, [], must_check_ty))
                          in
                       (match uu____476 with
                        | (scope,bs,must_check_ty) ->
                            let uu____604 = aux must_check_ty scope body  in
                            (match uu____604 with
                             | (res,must_check_ty) ->
                                 let c =
                                   match res with
                                   | FStar_Util.Inl t ->
                                       let uu____621 =
                                         FStar_Options.ml_ish ()  in
                                       (match uu____621 with
                                        | true  ->
                                            FStar_Syntax_Util.ml_comp t r
                                        | uu____622 ->
                                            FStar_Syntax_Syntax.mk_Total t)
                                   | FStar_Util.Inr c -> c  in
                                 let t = FStar_Syntax_Util.arrow bs c  in
                                 ((let uu____628 =
                                     FStar_TypeChecker_Env.debug env
                                       FStar_Options.High
                                      in
                                   match uu____628 with
                                   | true  ->
                                       let uu____629 =
                                         FStar_Range.string_of_range r  in
                                       let uu____630 =
                                         FStar_Syntax_Print.term_to_string t
                                          in
                                       let uu____631 =
                                         FStar_Util.string_of_bool
                                           must_check_ty
                                          in
                                       FStar_Util.print3
                                         "(%s) Using type %s .... must check = %s\n"
                                         uu____629 uu____630 uu____631
                                   | uu____632 -> ());
                                  ((FStar_Util.Inl t), must_check_ty))))
                   | uu____639 ->
                       (match must_check_ty with
                        | true  ->
                            ((FStar_Util.Inl FStar_Syntax_Syntax.tun), true)
                        | uu____646 ->
                            let uu____647 =
                              let uu____650 =
                                let uu____651 =
                                  FStar_TypeChecker_Rel.new_uvar r vars
                                    FStar_Syntax_Util.ktype0
                                   in
                                FStar_All.pipe_right uu____651 Prims.fst  in
                              FStar_Util.Inl uu____650  in
                            (uu____647, false))
                    in
                 let uu____658 =
                   let uu____663 = t_binders env  in aux false uu____663 e
                    in
                 match uu____658 with
                 | (t,b) ->
                     let t =
                       match t with
                       | FStar_Util.Inr c ->
                           let uu____680 =
                             FStar_Syntax_Util.is_tot_or_gtot_comp c  in
                           (match uu____680 with
                            | true  -> FStar_Syntax_Util.comp_result c
                            | uu____683 ->
                                let uu____684 =
                                  let uu____685 =
                                    let uu____688 =
                                      let uu____689 =
                                        FStar_Syntax_Print.comp_to_string c
                                         in
                                      FStar_Util.format1
                                        "Expected a 'let rec' to be annotated with a value type; got a computation type %s"
                                        uu____689
                                       in
                                    (uu____688, rng)  in
                                  FStar_Errors.Error uu____685  in
                                Prims.raise uu____684)
                       | FStar_Util.Inl t -> t  in
                     ([], t, b)))
           | uu____696 ->
               let uu____697 = FStar_Syntax_Subst.open_univ_vars univ_vars t
                  in
               (match uu____697 with | (univ_vars,t) -> (univ_vars, t, false)))
  
let pat_as_exps :
  Prims.bool ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.pat ->
        (FStar_Syntax_Syntax.bv Prims.list * FStar_Syntax_Syntax.term
          Prims.list * FStar_Syntax_Syntax.pat)
  =
  fun allow_implicits  ->
    fun env  ->
      fun p  ->
        let rec pat_as_arg_with_env allow_wc_dependence env p =
          match p.FStar_Syntax_Syntax.v with
          | FStar_Syntax_Syntax.Pat_constant c ->
              let e =
                (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_constant c))
                  None p.FStar_Syntax_Syntax.p
                 in
              ([], [], [], env, e, p)
          | FStar_Syntax_Syntax.Pat_dot_term (x,uu____780) ->
              let uu____785 = FStar_Syntax_Util.type_u ()  in
              (match uu____785 with
               | (k,uu____798) ->
                   let t = new_uvar env k  in
                   let x =
                     let uu___113_801 = x  in
                     {
                       FStar_Syntax_Syntax.ppname =
                         (uu___113_801.FStar_Syntax_Syntax.ppname);
                       FStar_Syntax_Syntax.index =
                         (uu___113_801.FStar_Syntax_Syntax.index);
                       FStar_Syntax_Syntax.sort = t
                     }  in
                   let uu____802 =
                     let uu____805 = FStar_TypeChecker_Env.all_binders env
                        in
                     FStar_TypeChecker_Rel.new_uvar p.FStar_Syntax_Syntax.p
                       uu____805 t
                      in
                   (match uu____802 with
                    | (e,u) ->
                        let p =
                          let uu___114_820 = p  in
                          {
                            FStar_Syntax_Syntax.v =
                              (FStar_Syntax_Syntax.Pat_dot_term (x, e));
                            FStar_Syntax_Syntax.ty =
                              (uu___114_820.FStar_Syntax_Syntax.ty);
                            FStar_Syntax_Syntax.p =
                              (uu___114_820.FStar_Syntax_Syntax.p)
                          }  in
                        ([], [], [], env, e, p)))
          | FStar_Syntax_Syntax.Pat_wild x ->
              let uu____827 = FStar_Syntax_Util.type_u ()  in
              (match uu____827 with
               | (t,uu____840) ->
                   let x =
                     let uu___115_842 = x  in
                     let uu____843 = new_uvar env t  in
                     {
                       FStar_Syntax_Syntax.ppname =
                         (uu___115_842.FStar_Syntax_Syntax.ppname);
                       FStar_Syntax_Syntax.index =
                         (uu___115_842.FStar_Syntax_Syntax.index);
                       FStar_Syntax_Syntax.sort = uu____843
                     }  in
                   let env =
                     match allow_wc_dependence with
                     | true  -> FStar_TypeChecker_Env.push_bv env x
                     | uu____847 -> env  in
                   let e =
                     (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_name x))
                       None p.FStar_Syntax_Syntax.p
                      in
                   ([x], [], [x], env, e, p))
          | FStar_Syntax_Syntax.Pat_var x ->
              let uu____865 = FStar_Syntax_Util.type_u ()  in
              (match uu____865 with
               | (t,uu____878) ->
                   let x =
                     let uu___116_880 = x  in
                     let uu____881 = new_uvar env t  in
                     {
                       FStar_Syntax_Syntax.ppname =
                         (uu___116_880.FStar_Syntax_Syntax.ppname);
                       FStar_Syntax_Syntax.index =
                         (uu___116_880.FStar_Syntax_Syntax.index);
                       FStar_Syntax_Syntax.sort = uu____881
                     }  in
                   let env = FStar_TypeChecker_Env.push_bv env x  in
                   let e =
                     (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_name x))
                       None p.FStar_Syntax_Syntax.p
                      in
                   ([x], [x], [], env, e, p))
          | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
              let uu____913 =
                FStar_All.pipe_right pats
                  (FStar_List.fold_left
                     (fun uu____969  ->
                        fun uu____970  ->
                          match (uu____969, uu____970) with
                          | ((b,a,w,env,args,pats),(p,imp)) ->
                              let uu____1069 =
                                pat_as_arg_with_env allow_wc_dependence env p
                                 in
                              (match uu____1069 with
                               | (b',a',w',env,te,pat) ->
                                   let arg =
                                     match imp with
                                     | true  -> FStar_Syntax_Syntax.iarg te
                                     | uu____1108 ->
                                         FStar_Syntax_Syntax.as_arg te
                                      in
                                   ((b' :: b), (a' :: a), (w' :: w), env,
                                     (arg :: args), ((pat, imp) :: pats))))
                     ([], [], [], env, [], []))
                 in
              (match uu____913 with
               | (b,a,w,env,args,pats) ->
                   let e =
                     let uu____1177 =
                       let uu____1180 =
                         let uu____1181 =
                           let uu____1186 =
                             let uu____1189 =
                               let uu____1190 =
                                 FStar_Syntax_Syntax.fv_to_tm fv  in
                               let uu____1191 =
                                 FStar_All.pipe_right args FStar_List.rev  in
                               FStar_Syntax_Syntax.mk_Tm_app uu____1190
                                 uu____1191
                                in
                             uu____1189 None p.FStar_Syntax_Syntax.p  in
                           (uu____1186,
                             (FStar_Syntax_Syntax.Meta_desugared
                                FStar_Syntax_Syntax.Data_app))
                            in
                         FStar_Syntax_Syntax.Tm_meta uu____1181  in
                       FStar_Syntax_Syntax.mk uu____1180  in
                     uu____1177 None p.FStar_Syntax_Syntax.p  in
                   let uu____1208 =
                     FStar_All.pipe_right (FStar_List.rev b)
                       FStar_List.flatten
                      in
                   let uu____1214 =
                     FStar_All.pipe_right (FStar_List.rev a)
                       FStar_List.flatten
                      in
                   let uu____1220 =
                     FStar_All.pipe_right (FStar_List.rev w)
                       FStar_List.flatten
                      in
                   (uu____1208, uu____1214, uu____1220, env, e,
                     (let uu___117_1233 = p  in
                      {
                        FStar_Syntax_Syntax.v =
                          (FStar_Syntax_Syntax.Pat_cons
                             (fv, (FStar_List.rev pats)));
                        FStar_Syntax_Syntax.ty =
                          (uu___117_1233.FStar_Syntax_Syntax.ty);
                        FStar_Syntax_Syntax.p =
                          (uu___117_1233.FStar_Syntax_Syntax.p)
                      })))
          | FStar_Syntax_Syntax.Pat_disj uu____1239 -> failwith "impossible"
           in
        let rec elaborate_pat env p =
          let maybe_dot inaccessible a r =
            match allow_implicits && inaccessible with
            | true  ->
                FStar_Syntax_Syntax.withinfo
                  (FStar_Syntax_Syntax.Pat_dot_term
                     (a, FStar_Syntax_Syntax.tun))
                  FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n r
            | uu____1279 ->
                FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_var a)
                  FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n r
             in
          match p.FStar_Syntax_Syntax.v with
          | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
              let pats =
                FStar_List.map
                  (fun uu____1308  ->
                     match uu____1308 with
                     | (p,imp) ->
                         let uu____1323 = elaborate_pat env p  in
                         (uu____1323, imp)) pats
                 in
              let uu____1328 =
                FStar_TypeChecker_Env.lookup_datacon env
                  (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                 in
              (match uu____1328 with
               | (uu____1337,t) ->
                   let uu____1339 = FStar_Syntax_Util.arrow_formals t  in
                   (match uu____1339 with
                    | (f,uu____1350) ->
                        let rec aux formals pats =
                          match (formals, pats) with
                          | ([],[]) -> []
                          | ([],uu____1425::uu____1426) ->
                              Prims.raise
                                (FStar_Errors.Error
                                   ("Too many pattern arguments",
                                     (FStar_Ident.range_of_lid
                                        (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)))
                          | (uu____1461::uu____1462,[]) ->
                              FStar_All.pipe_right formals
                                (FStar_List.map
                                   (fun uu____1502  ->
                                      match uu____1502 with
                                      | (t,imp) ->
                                          (match imp with
                                           | Some
                                               (FStar_Syntax_Syntax.Implicit
                                               inaccessible) ->
                                               let a =
                                                 let uu____1520 =
                                                   let uu____1522 =
                                                     FStar_Syntax_Syntax.range_of_bv
                                                       t
                                                      in
                                                   Some uu____1522  in
                                                 FStar_Syntax_Syntax.new_bv
                                                   uu____1520
                                                   FStar_Syntax_Syntax.tun
                                                  in
                                               let r =
                                                 FStar_Ident.range_of_lid
                                                   (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                                  in
                                               let uu____1528 =
                                                 maybe_dot inaccessible a r
                                                  in
                                               (uu____1528, true)
                                           | uu____1533 ->
                                               let uu____1535 =
                                                 let uu____1536 =
                                                   let uu____1539 =
                                                     let uu____1540 =
                                                       FStar_Syntax_Print.pat_to_string
                                                         p
                                                        in
                                                     FStar_Util.format1
                                                       "Insufficient pattern arguments (%s)"
                                                       uu____1540
                                                      in
                                                   (uu____1539,
                                                     (FStar_Ident.range_of_lid
                                                        (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v))
                                                    in
                                                 FStar_Errors.Error
                                                   uu____1536
                                                  in
                                               Prims.raise uu____1535)))
                          | (f::formals',(p,p_imp)::pats') ->
                              (match f with
                               | (uu____1591,Some
                                  (FStar_Syntax_Syntax.Implicit uu____1592))
                                   when p_imp ->
                                   let uu____1594 = aux formals' pats'  in
                                   (p, true) :: uu____1594
                               | (uu____1606,Some
                                  (FStar_Syntax_Syntax.Implicit
                                  inaccessible)) ->
                                   let a =
                                     FStar_Syntax_Syntax.new_bv
                                       (Some (p.FStar_Syntax_Syntax.p))
                                       FStar_Syntax_Syntax.tun
                                      in
                                   let p =
                                     maybe_dot inaccessible a
                                       (FStar_Ident.range_of_lid
                                          (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)
                                      in
                                   let uu____1617 = aux formals' pats  in
                                   (p, true) :: uu____1617
                               | (uu____1629,imp) ->
                                   let uu____1633 =
                                     let uu____1638 =
                                       FStar_Syntax_Syntax.is_implicit imp
                                        in
                                     (p, uu____1638)  in
                                   let uu____1641 = aux formals' pats'  in
                                   uu____1633 :: uu____1641)
                           in
                        let uu___118_1651 = p  in
                        let uu____1654 =
                          let uu____1655 =
                            let uu____1663 = aux f pats  in (fv, uu____1663)
                             in
                          FStar_Syntax_Syntax.Pat_cons uu____1655  in
                        {
                          FStar_Syntax_Syntax.v = uu____1654;
                          FStar_Syntax_Syntax.ty =
                            (uu___118_1651.FStar_Syntax_Syntax.ty);
                          FStar_Syntax_Syntax.p =
                            (uu___118_1651.FStar_Syntax_Syntax.p)
                        }))
          | uu____1674 -> p  in
        let one_pat allow_wc_dependence env p =
          let p = elaborate_pat env p  in
          let uu____1700 = pat_as_arg_with_env allow_wc_dependence env p  in
          match uu____1700 with
          | (b,a,w,env,arg,p) ->
              let uu____1730 =
                FStar_All.pipe_right b
                  (FStar_Util.find_dup FStar_Syntax_Syntax.bv_eq)
                 in
              (match uu____1730 with
               | Some x ->
                   let uu____1743 =
                     let uu____1744 =
                       let uu____1747 =
                         FStar_TypeChecker_Err.nonlinear_pattern_variable x
                          in
                       (uu____1747, (p.FStar_Syntax_Syntax.p))  in
                     FStar_Errors.Error uu____1744  in
                   Prims.raise uu____1743
               | uu____1756 -> (b, a, w, arg, p))
           in
        let top_level_pat_as_args env p =
          match p.FStar_Syntax_Syntax.v with
          | FStar_Syntax_Syntax.Pat_disj [] -> failwith "impossible"
          | FStar_Syntax_Syntax.Pat_disj (q::pats) ->
              let uu____1799 = one_pat false env q  in
              (match uu____1799 with
               | (b,a,uu____1815,te,q) ->
                   let uu____1824 =
                     FStar_List.fold_right
                       (fun p  ->
                          fun uu____1840  ->
                            match uu____1840 with
                            | (w,args,pats) ->
                                let uu____1864 = one_pat false env p  in
                                (match uu____1864 with
                                 | (b',a',w',arg,p) ->
                                     let uu____1890 =
                                       let uu____1891 =
                                         FStar_Util.multiset_equiv
                                           FStar_Syntax_Syntax.bv_eq a a'
                                          in
                                       Prims.op_Negation uu____1891  in
                                     (match uu____1890 with
                                      | true  ->
                                          let uu____1898 =
                                            let uu____1899 =
                                              let uu____1902 =
                                                FStar_TypeChecker_Err.disjunctive_pattern_vars
                                                  a a'
                                                 in
                                              let uu____1903 =
                                                FStar_TypeChecker_Env.get_range
                                                  env
                                                 in
                                              (uu____1902, uu____1903)  in
                                            FStar_Errors.Error uu____1899  in
                                          Prims.raise uu____1898
                                      | uu____1910 ->
                                          let uu____1911 =
                                            let uu____1913 =
                                              FStar_Syntax_Syntax.as_arg arg
                                               in
                                            uu____1913 :: args  in
                                          ((FStar_List.append w' w),
                                            uu____1911, (p :: pats))))) pats
                       ([], [], [])
                      in
                   (match uu____1824 with
                    | (w,args,pats) ->
                        let uu____1934 =
                          let uu____1936 = FStar_Syntax_Syntax.as_arg te  in
                          uu____1936 :: args  in
                        ((FStar_List.append b w), uu____1934,
                          (let uu___119_1941 = p  in
                           {
                             FStar_Syntax_Syntax.v =
                               (FStar_Syntax_Syntax.Pat_disj (q :: pats));
                             FStar_Syntax_Syntax.ty =
                               (uu___119_1941.FStar_Syntax_Syntax.ty);
                             FStar_Syntax_Syntax.p =
                               (uu___119_1941.FStar_Syntax_Syntax.p)
                           }))))
          | uu____1942 ->
              let uu____1943 = one_pat true env p  in
              (match uu____1943 with
               | (b,uu____1958,uu____1959,arg,p) ->
                   let uu____1968 =
                     let uu____1970 = FStar_Syntax_Syntax.as_arg arg  in
                     [uu____1970]  in
                   (b, uu____1968, p))
           in
        let uu____1973 = top_level_pat_as_args env p  in
        match uu____1973 with
        | (b,args,p) ->
            let exps = FStar_All.pipe_right args (FStar_List.map Prims.fst)
               in
            (b, exps, p)
  
let decorate_pattern :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.pat ->
      FStar_Syntax_Syntax.term Prims.list -> FStar_Syntax_Syntax.pat
  =
  fun env  ->
    fun p  ->
      fun exps  ->
        let qq = p  in
        let rec aux p e =
          let pkg q t =
            FStar_Syntax_Syntax.withinfo q t p.FStar_Syntax_Syntax.p  in
          let e = FStar_Syntax_Util.unmeta e  in
          match ((p.FStar_Syntax_Syntax.v), (e.FStar_Syntax_Syntax.n)) with
          | (uu____2044,FStar_Syntax_Syntax.Tm_uinst (e,uu____2046)) ->
              aux p e
          | (FStar_Syntax_Syntax.Pat_constant
             uu____2051,FStar_Syntax_Syntax.Tm_constant uu____2052) ->
              let uu____2053 = force_sort' e  in
              pkg p.FStar_Syntax_Syntax.v uu____2053
          | (FStar_Syntax_Syntax.Pat_var x,FStar_Syntax_Syntax.Tm_name y) ->
              ((match Prims.op_Negation (FStar_Syntax_Syntax.bv_eq x y) with
                | true  ->
                    let uu____2057 =
                      let uu____2058 = FStar_Syntax_Print.bv_to_string x  in
                      let uu____2059 = FStar_Syntax_Print.bv_to_string y  in
                      FStar_Util.format2
                        "Expected pattern variable %s; got %s" uu____2058
                        uu____2059
                       in
                    failwith uu____2057
                | uu____2060 -> ());
               (let uu____2062 =
                  FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                    (FStar_Options.Other "Pat")
                   in
                match uu____2062 with
                | true  ->
                    let uu____2063 = FStar_Syntax_Print.bv_to_string x  in
                    let uu____2064 =
                      FStar_TypeChecker_Normalize.term_to_string env
                        y.FStar_Syntax_Syntax.sort
                       in
                    FStar_Util.print2
                      "Pattern variable %s introduced at type %s\n"
                      uu____2063 uu____2064
                | uu____2065 -> ());
               (let s =
                  FStar_TypeChecker_Normalize.normalize
                    [FStar_TypeChecker_Normalize.Beta] env
                    y.FStar_Syntax_Syntax.sort
                   in
                let x =
                  let uu___120_2068 = x  in
                  {
                    FStar_Syntax_Syntax.ppname =
                      (uu___120_2068.FStar_Syntax_Syntax.ppname);
                    FStar_Syntax_Syntax.index =
                      (uu___120_2068.FStar_Syntax_Syntax.index);
                    FStar_Syntax_Syntax.sort = s
                  }  in
                pkg (FStar_Syntax_Syntax.Pat_var x) s.FStar_Syntax_Syntax.n))
          | (FStar_Syntax_Syntax.Pat_wild x,FStar_Syntax_Syntax.Tm_name y) ->
              ((let uu____2072 =
                  FStar_All.pipe_right (FStar_Syntax_Syntax.bv_eq x y)
                    Prims.op_Negation
                   in
                match uu____2072 with
                | true  ->
                    let uu____2073 =
                      let uu____2074 = FStar_Syntax_Print.bv_to_string x  in
                      let uu____2075 = FStar_Syntax_Print.bv_to_string y  in
                      FStar_Util.format2
                        "Expected pattern variable %s; got %s" uu____2074
                        uu____2075
                       in
                    failwith uu____2073
                | uu____2076 -> ());
               (let s =
                  FStar_TypeChecker_Normalize.normalize
                    [FStar_TypeChecker_Normalize.Beta] env
                    y.FStar_Syntax_Syntax.sort
                   in
                let x =
                  let uu___121_2079 = x  in
                  {
                    FStar_Syntax_Syntax.ppname =
                      (uu___121_2079.FStar_Syntax_Syntax.ppname);
                    FStar_Syntax_Syntax.index =
                      (uu___121_2079.FStar_Syntax_Syntax.index);
                    FStar_Syntax_Syntax.sort = s
                  }  in
                pkg (FStar_Syntax_Syntax.Pat_wild x) s.FStar_Syntax_Syntax.n))
          | (FStar_Syntax_Syntax.Pat_dot_term (x,uu____2081),uu____2082) ->
              let s = force_sort e  in
              let x =
                let uu___122_2091 = x  in
                {
                  FStar_Syntax_Syntax.ppname =
                    (uu___122_2091.FStar_Syntax_Syntax.ppname);
                  FStar_Syntax_Syntax.index =
                    (uu___122_2091.FStar_Syntax_Syntax.index);
                  FStar_Syntax_Syntax.sort = s
                }  in
              pkg (FStar_Syntax_Syntax.Pat_dot_term (x, e))
                s.FStar_Syntax_Syntax.n
          | (FStar_Syntax_Syntax.Pat_cons (fv,[]),FStar_Syntax_Syntax.Tm_fvar
             fv') ->
              ((let uu____2104 =
                  let uu____2105 = FStar_Syntax_Syntax.fv_eq fv fv'  in
                  Prims.op_Negation uu____2105  in
                match uu____2104 with
                | true  ->
                    let uu____2106 =
                      FStar_Util.format2
                        "Expected pattern constructor %s; got %s"
                        ((fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                        ((fv'.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                       in
                    failwith uu____2106
                | uu____2115 -> ());
               (let uu____2116 = force_sort' e  in
                pkg (FStar_Syntax_Syntax.Pat_cons (fv', [])) uu____2116))
          | (FStar_Syntax_Syntax.Pat_cons
             (fv,argpats),FStar_Syntax_Syntax.Tm_app
             ({ FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar fv';
                FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _;
                FStar_Syntax_Syntax.vars = _;_},args))
            |(FStar_Syntax_Syntax.Pat_cons
              (fv,argpats),FStar_Syntax_Syntax.Tm_app
              ({
                 FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_uinst
                   ({
                      FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar fv';
                      FStar_Syntax_Syntax.tk = _;
                      FStar_Syntax_Syntax.pos = _;
                      FStar_Syntax_Syntax.vars = _;_},_);
                 FStar_Syntax_Syntax.tk = _; FStar_Syntax_Syntax.pos = _;
                 FStar_Syntax_Syntax.vars = _;_},args))
              ->
              ((let uu____2187 =
                  let uu____2188 = FStar_Syntax_Syntax.fv_eq fv fv'  in
                  FStar_All.pipe_right uu____2188 Prims.op_Negation  in
                match uu____2187 with
                | true  ->
                    let uu____2189 =
                      FStar_Util.format2
                        "Expected pattern constructor %s; got %s"
                        ((fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                        ((fv'.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v).FStar_Ident.str
                       in
                    failwith uu____2189
                | uu____2198 -> ());
               (let fv = fv'  in
                let rec match_args matched_pats args argpats =
                  match (args, argpats) with
                  | ([],[]) ->
                      let uu____2277 = force_sort' e  in
                      pkg
                        (FStar_Syntax_Syntax.Pat_cons
                           (fv, (FStar_List.rev matched_pats))) uu____2277
                  | (arg::args,(argpat,uu____2290)::argpats) ->
                      (match (arg, (argpat.FStar_Syntax_Syntax.v)) with
                       | ((e,Some (FStar_Syntax_Syntax.Implicit (true ))),FStar_Syntax_Syntax.Pat_dot_term
                          uu____2340) ->
                           let x =
                             let uu____2356 = force_sort e  in
                             FStar_Syntax_Syntax.new_bv
                               (Some (p.FStar_Syntax_Syntax.p)) uu____2356
                              in
                           let q =
                             FStar_Syntax_Syntax.withinfo
                               (FStar_Syntax_Syntax.Pat_dot_term (x, e))
                               (x.FStar_Syntax_Syntax.sort).FStar_Syntax_Syntax.n
                               p.FStar_Syntax_Syntax.p
                              in
                           match_args ((q, true) :: matched_pats) args
                             argpats
                       | ((e,imp),uu____2370) ->
                           let pat =
                             let uu____2385 = aux argpat e  in
                             let uu____2386 =
                               FStar_Syntax_Syntax.is_implicit imp  in
                             (uu____2385, uu____2386)  in
                           match_args (pat :: matched_pats) args argpats)
                  | uu____2389 ->
                      let uu____2403 =
                        let uu____2404 = FStar_Syntax_Print.pat_to_string p
                           in
                        let uu____2405 = FStar_Syntax_Print.term_to_string e
                           in
                        FStar_Util.format2
                          "Unexpected number of pattern arguments: \n\t%s\n\t%s\n"
                          uu____2404 uu____2405
                         in
                      failwith uu____2403
                   in
                match_args [] args argpats))
          | uu____2412 ->
              let uu____2415 =
                let uu____2416 =
                  FStar_Range.string_of_range qq.FStar_Syntax_Syntax.p  in
                let uu____2417 = FStar_Syntax_Print.pat_to_string qq  in
                let uu____2418 =
                  let uu____2419 =
                    FStar_All.pipe_right exps
                      (FStar_List.map FStar_Syntax_Print.term_to_string)
                     in
                  FStar_All.pipe_right uu____2419
                    (FStar_String.concat "\n\t")
                   in
                FStar_Util.format3
                  "(%s) Impossible: pattern to decorate is %s; expression is %s\n"
                  uu____2416 uu____2417 uu____2418
                 in
              failwith uu____2415
           in
        match ((p.FStar_Syntax_Syntax.v), exps) with
        | (FStar_Syntax_Syntax.Pat_disj ps,uu____2426) when
            (FStar_List.length ps) = (FStar_List.length exps) ->
            let ps = FStar_List.map2 aux ps exps  in
            FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_disj ps)
              FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n
              p.FStar_Syntax_Syntax.p
        | (uu____2442,e::[]) -> aux p e
        | uu____2445 -> failwith "Unexpected number of patterns"
  
let rec decorated_pattern_as_term :
  FStar_Syntax_Syntax.pat ->
    (FStar_Syntax_Syntax.bv Prims.list * FStar_Syntax_Syntax.term)
  =
  fun pat  ->
    let topt = Some (pat.FStar_Syntax_Syntax.ty)  in
    let mk f = (FStar_Syntax_Syntax.mk f) topt pat.FStar_Syntax_Syntax.p  in
    let pat_as_arg uu____2482 =
      match uu____2482 with
      | (p,i) ->
          let uu____2492 = decorated_pattern_as_term p  in
          (match uu____2492 with
           | (vars,te) ->
               let uu____2505 =
                 let uu____2508 = FStar_Syntax_Syntax.as_implicit i  in
                 (te, uu____2508)  in
               (vars, uu____2505))
       in
    match pat.FStar_Syntax_Syntax.v with
    | FStar_Syntax_Syntax.Pat_disj uu____2515 -> failwith "Impossible"
    | FStar_Syntax_Syntax.Pat_constant c ->
        let uu____2523 = mk (FStar_Syntax_Syntax.Tm_constant c)  in
        ([], uu____2523)
    | FStar_Syntax_Syntax.Pat_wild x|FStar_Syntax_Syntax.Pat_var x ->
        let uu____2526 = mk (FStar_Syntax_Syntax.Tm_name x)  in
        ([x], uu____2526)
    | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
        let uu____2540 =
          let uu____2548 =
            FStar_All.pipe_right pats (FStar_List.map pat_as_arg)  in
          FStar_All.pipe_right uu____2548 FStar_List.unzip  in
        (match uu____2540 with
         | (vars,args) ->
             let vars = FStar_List.flatten vars  in
             let uu____2606 =
               let uu____2607 =
                 let uu____2608 =
                   let uu____2618 = FStar_Syntax_Syntax.fv_to_tm fv  in
                   (uu____2618, args)  in
                 FStar_Syntax_Syntax.Tm_app uu____2608  in
               mk uu____2607  in
             (vars, uu____2606))
    | FStar_Syntax_Syntax.Pat_dot_term (x,e) -> ([], e)
  
let destruct_comp :
  FStar_Syntax_Syntax.comp_typ ->
    (FStar_Syntax_Syntax.universe *
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax *
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax)
  =
  fun c  ->
    let wp =
      match c.FStar_Syntax_Syntax.effect_args with
      | (wp,uu____2647)::[] -> wp
      | uu____2660 ->
          let uu____2666 =
            let uu____2667 =
              let uu____2668 =
                FStar_List.map
                  (fun uu____2672  ->
                     match uu____2672 with
                     | (x,uu____2676) -> FStar_Syntax_Print.term_to_string x)
                  c.FStar_Syntax_Syntax.effect_args
                 in
              FStar_All.pipe_right uu____2668 (FStar_String.concat ", ")  in
            FStar_Util.format2
              "Impossible: Got a computation %s with effect args [%s]"
              (c.FStar_Syntax_Syntax.effect_name).FStar_Ident.str uu____2667
             in
          failwith uu____2666
       in
    let uu____2680 = FStar_List.hd c.FStar_Syntax_Syntax.comp_univs  in
    (uu____2680, (c.FStar_Syntax_Syntax.result_typ), wp)
  
let lift_comp :
  FStar_Syntax_Syntax.comp_typ ->
    FStar_Ident.lident ->
      ((FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
         FStar_Syntax_Syntax.syntax ->
         FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.term)
        -> FStar_Syntax_Syntax.comp_typ
  =
  fun c  ->
    fun m  ->
      fun lift  ->
        let uu____2708 = destruct_comp c  in
        match uu____2708 with
        | (u,uu____2713,wp) ->
            let uu____2715 =
              let uu____2721 =
                let uu____2722 = lift c.FStar_Syntax_Syntax.result_typ wp  in
                FStar_Syntax_Syntax.as_arg uu____2722  in
              [uu____2721]  in
            {
              FStar_Syntax_Syntax.comp_univs = [u];
              FStar_Syntax_Syntax.effect_name = m;
              FStar_Syntax_Syntax.result_typ =
                (c.FStar_Syntax_Syntax.result_typ);
              FStar_Syntax_Syntax.effect_args = uu____2715;
              FStar_Syntax_Syntax.flags = []
            }
  
let join_effects :
  FStar_TypeChecker_Env.env ->
    FStar_Ident.lident -> FStar_Ident.lident -> FStar_Ident.lident
  =
  fun env  ->
    fun l1  ->
      fun l2  ->
        let uu____2732 =
          let uu____2736 = FStar_TypeChecker_Env.norm_eff_name env l1  in
          let uu____2737 = FStar_TypeChecker_Env.norm_eff_name env l2  in
          FStar_TypeChecker_Env.join env uu____2736 uu____2737  in
        match uu____2732 with | (m,uu____2739,uu____2740) -> m
  
let join_lcomp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.lcomp ->
      FStar_Syntax_Syntax.lcomp -> FStar_Ident.lident
  =
  fun env  ->
    fun c1  ->
      fun c2  ->
        let uu____2750 =
          (FStar_Syntax_Util.is_total_lcomp c1) &&
            (FStar_Syntax_Util.is_total_lcomp c2)
           in
        match uu____2750 with
        | true  -> FStar_Syntax_Const.effect_Tot_lid
        | uu____2751 ->
            join_effects env c1.FStar_Syntax_Syntax.eff_name
              c2.FStar_Syntax_Syntax.eff_name
  
let lift_and_destruct :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.comp ->
      FStar_Syntax_Syntax.comp ->
        ((FStar_Syntax_Syntax.eff_decl * FStar_Syntax_Syntax.bv *
          FStar_Syntax_Syntax.term) * (FStar_Syntax_Syntax.universe *
          FStar_Syntax_Syntax.typ * FStar_Syntax_Syntax.typ) *
          (FStar_Syntax_Syntax.universe * FStar_Syntax_Syntax.typ *
          FStar_Syntax_Syntax.typ))
  =
  fun env  ->
    fun c1  ->
      fun c2  ->
        let c1 = FStar_TypeChecker_Normalize.unfold_effect_abbrev env c1  in
        let c2 = FStar_TypeChecker_Normalize.unfold_effect_abbrev env c2  in
        let uu____2775 =
          FStar_TypeChecker_Env.join env c1.FStar_Syntax_Syntax.effect_name
            c2.FStar_Syntax_Syntax.effect_name
           in
        match uu____2775 with
        | (m,lift1,lift2) ->
            let m1 = lift_comp c1 m lift1  in
            let m2 = lift_comp c2 m lift2  in
            let md = FStar_TypeChecker_Env.get_effect_decl env m  in
            let uu____2805 =
              FStar_TypeChecker_Env.wp_signature env
                md.FStar_Syntax_Syntax.mname
               in
            (match uu____2805 with
             | (a,kwp) ->
                 let uu____2822 = destruct_comp m1  in
                 let uu____2826 = destruct_comp m2  in
                 ((md, a, kwp), uu____2822, uu____2826))
  
let is_pure_effect :
  FStar_TypeChecker_Env.env -> FStar_Ident.lident -> Prims.bool =
  fun env  ->
    fun l  ->
      let l = FStar_TypeChecker_Env.norm_eff_name env l  in
      FStar_Ident.lid_equals l FStar_Syntax_Const.effect_PURE_lid
  
let is_pure_or_ghost_effect :
  FStar_TypeChecker_Env.env -> FStar_Ident.lident -> Prims.bool =
  fun env  ->
    fun l  ->
      let l = FStar_TypeChecker_Env.norm_eff_name env l  in
      (FStar_Ident.lid_equals l FStar_Syntax_Const.effect_PURE_lid) ||
        (FStar_Ident.lid_equals l FStar_Syntax_Const.effect_GHOST_lid)
  
let mk_comp_l :
  FStar_Ident.lident ->
    FStar_Syntax_Syntax.universe ->
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax ->
        FStar_Syntax_Syntax.term ->
          FStar_Syntax_Syntax.cflags Prims.list -> FStar_Syntax_Syntax.comp
  =
  fun mname  ->
    fun u_result  ->
      fun result  ->
        fun wp  ->
          fun flags  ->
            let uu____2874 =
              let uu____2875 =
                let uu____2881 = FStar_Syntax_Syntax.as_arg wp  in
                [uu____2881]  in
              {
                FStar_Syntax_Syntax.comp_univs = [u_result];
                FStar_Syntax_Syntax.effect_name = mname;
                FStar_Syntax_Syntax.result_typ = result;
                FStar_Syntax_Syntax.effect_args = uu____2875;
                FStar_Syntax_Syntax.flags = flags
              }  in
            FStar_Syntax_Syntax.mk_Comp uu____2874
  
let mk_comp :
  FStar_Syntax_Syntax.eff_decl ->
    FStar_Syntax_Syntax.universe ->
      (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax ->
        FStar_Syntax_Syntax.term ->
          FStar_Syntax_Syntax.cflags Prims.list -> FStar_Syntax_Syntax.comp
  = fun md  -> mk_comp_l md.FStar_Syntax_Syntax.mname 
let lax_mk_tot_or_comp_l :
  FStar_Ident.lident ->
    FStar_Syntax_Syntax.universe ->
      FStar_Syntax_Syntax.typ ->
        FStar_Syntax_Syntax.cflags Prims.list -> FStar_Syntax_Syntax.comp
  =
  fun mname  ->
    fun u_result  ->
      fun result  ->
        fun flags  ->
          match FStar_Ident.lid_equals mname
                  FStar_Syntax_Const.effect_Tot_lid
          with
          | true  -> FStar_Syntax_Syntax.mk_Total' result (Some u_result)
          | uu____2910 ->
              mk_comp_l mname u_result result FStar_Syntax_Syntax.tun flags
  
let subst_lcomp :
  FStar_Syntax_Syntax.subst_t ->
    FStar_Syntax_Syntax.lcomp -> FStar_Syntax_Syntax.lcomp
  =
  fun subst  ->
    fun lc  ->
      let uu___123_2917 = lc  in
      let uu____2918 =
        FStar_Syntax_Subst.subst subst lc.FStar_Syntax_Syntax.res_typ  in
      {
        FStar_Syntax_Syntax.eff_name =
          (uu___123_2917.FStar_Syntax_Syntax.eff_name);
        FStar_Syntax_Syntax.res_typ = uu____2918;
        FStar_Syntax_Syntax.cflags =
          (uu___123_2917.FStar_Syntax_Syntax.cflags);
        FStar_Syntax_Syntax.comp =
          (fun uu____2921  ->
             let uu____2922 = lc.FStar_Syntax_Syntax.comp ()  in
             FStar_Syntax_Subst.subst_comp subst uu____2922)
      }
  
let is_function : FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____2926 =
      let uu____2927 = FStar_Syntax_Subst.compress t  in
      uu____2927.FStar_Syntax_Syntax.n  in
    match uu____2926 with
    | FStar_Syntax_Syntax.Tm_arrow uu____2930 -> true
    | uu____2938 -> false
  
let return_value :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.typ ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.comp
  =
  fun env  ->
    fun t  ->
      fun v  ->
        let c =
          let uu____2949 =
            let uu____2950 =
              FStar_TypeChecker_Env.lid_exists env
                FStar_Syntax_Const.effect_GTot_lid
               in
            FStar_All.pipe_left Prims.op_Negation uu____2950  in
          match uu____2949 with
          | true  -> FStar_Syntax_Syntax.mk_Total t
          | uu____2951 ->
              let m =
                let uu____2953 =
                  FStar_TypeChecker_Env.effect_decl_opt env
                    FStar_Syntax_Const.effect_PURE_lid
                   in
                FStar_Util.must uu____2953  in
              let u_t = env.FStar_TypeChecker_Env.universe_of env t  in
              let wp =
                let uu____2957 =
                  env.FStar_TypeChecker_Env.lax && (FStar_Options.ml_ish ())
                   in
                match uu____2957 with
                | true  -> FStar_Syntax_Syntax.tun
                | uu____2958 ->
                    let uu____2959 =
                      FStar_TypeChecker_Env.wp_signature env
                        FStar_Syntax_Const.effect_PURE_lid
                       in
                    (match uu____2959 with
                     | (a,kwp) ->
                         let k =
                           FStar_Syntax_Subst.subst
                             [FStar_Syntax_Syntax.NT (a, t)] kwp
                            in
                         let uu____2965 =
                           let uu____2966 =
                             let uu____2967 =
                               FStar_TypeChecker_Env.inst_effect_fun_with
                                 [u_t] env m m.FStar_Syntax_Syntax.ret_wp
                                in
                             let uu____2968 =
                               let uu____2969 = FStar_Syntax_Syntax.as_arg t
                                  in
                               let uu____2970 =
                                 let uu____2972 =
                                   FStar_Syntax_Syntax.as_arg v  in
                                 [uu____2972]  in
                               uu____2969 :: uu____2970  in
                             FStar_Syntax_Syntax.mk_Tm_app uu____2967
                               uu____2968
                              in
                           uu____2966 (Some (k.FStar_Syntax_Syntax.n))
                             v.FStar_Syntax_Syntax.pos
                            in
                         FStar_TypeChecker_Normalize.normalize
                           [FStar_TypeChecker_Normalize.Beta] env uu____2965)
                 in
              (mk_comp m) u_t t wp [FStar_Syntax_Syntax.RETURN]
           in
        (let uu____2978 =
           FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
             (FStar_Options.Other "Return")
            in
         match uu____2978 with
         | true  ->
             let uu____2979 =
               FStar_Range.string_of_range v.FStar_Syntax_Syntax.pos  in
             let uu____2980 = FStar_Syntax_Print.term_to_string v  in
             let uu____2981 =
               FStar_TypeChecker_Normalize.comp_to_string env c  in
             FStar_Util.print3 "(%s) returning %s at comp type %s\n"
               uu____2979 uu____2980 uu____2981
         | uu____2982 -> ());
        c
  
let bind :
  FStar_Range.range ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term Prims.option ->
        FStar_Syntax_Syntax.lcomp ->
          lcomp_with_binder -> FStar_Syntax_Syntax.lcomp
  =
  fun r1  ->
    fun env  ->
      fun e1opt  ->
        fun lc1  ->
          fun uu____2998  ->
            match uu____2998 with
            | (b,lc2) ->
                let lc1 =
                  FStar_TypeChecker_Normalize.ghost_to_pure_lcomp env lc1  in
                let lc2 =
                  FStar_TypeChecker_Normalize.ghost_to_pure_lcomp env lc2  in
                let joined_eff = join_lcomp env lc1 lc2  in
                ((let uu____3008 =
                    FStar_TypeChecker_Env.debug env FStar_Options.Extreme  in
                  match uu____3008 with
                  | true  ->
                      let bstr =
                        match b with
                        | None  -> "none"
                        | Some x -> FStar_Syntax_Print.bv_to_string x  in
                      let uu____3011 =
                        match e1opt with
                        | None  -> "None"
                        | Some e -> FStar_Syntax_Print.term_to_string e  in
                      let uu____3013 = FStar_Syntax_Print.lcomp_to_string lc1
                         in
                      let uu____3014 = FStar_Syntax_Print.lcomp_to_string lc2
                         in
                      FStar_Util.print4
                        "Before lift: Making bind (e1=%s)@c1=%s\nb=%s\t\tc2=%s\n"
                        uu____3011 uu____3013 bstr uu____3014
                  | uu____3015 -> ());
                 (let bind_it uu____3019 =
                    let uu____3020 =
                      env.FStar_TypeChecker_Env.lax &&
                        (FStar_Options.ml_ish ())
                       in
                    match uu____3020 with
                    | true  ->
                        let u_t =
                          env.FStar_TypeChecker_Env.universe_of env
                            lc2.FStar_Syntax_Syntax.res_typ
                           in
                        lax_mk_tot_or_comp_l joined_eff u_t
                          lc2.FStar_Syntax_Syntax.res_typ []
                    | uu____3022 ->
                        let c1 = lc1.FStar_Syntax_Syntax.comp ()  in
                        let c2 = lc2.FStar_Syntax_Syntax.comp ()  in
                        ((let uu____3030 =
                            FStar_TypeChecker_Env.debug env
                              FStar_Options.Extreme
                             in
                          match uu____3030 with
                          | true  ->
                              let uu____3031 =
                                match b with
                                | None  -> "none"
                                | Some x -> FStar_Syntax_Print.bv_to_string x
                                 in
                              let uu____3033 =
                                FStar_Syntax_Print.lcomp_to_string lc1  in
                              let uu____3034 =
                                FStar_Syntax_Print.comp_to_string c1  in
                              let uu____3035 =
                                FStar_Syntax_Print.lcomp_to_string lc2  in
                              let uu____3036 =
                                FStar_Syntax_Print.comp_to_string c2  in
                              FStar_Util.print5
                                "b=%s,Evaluated %s to %s\n And %s to %s\n"
                                uu____3031 uu____3033 uu____3034 uu____3035
                                uu____3036
                          | uu____3037 -> ());
                         (let try_simplify uu____3044 =
                            let aux uu____3053 =
                              let uu____3054 =
                                FStar_Syntax_Util.is_trivial_wp c1  in
                              match uu____3054 with
                              | true  ->
                                  (match b with
                                   | None  -> Some (c2, "trivial no binder")
                                   | Some uu____3071 ->
                                       let uu____3072 =
                                         FStar_Syntax_Util.is_ml_comp c2  in
                                       (match uu____3072 with
                                        | true  -> Some (c2, "trivial ml")
                                        | uu____3084 -> None))
                              | uu____3089 ->
                                  let uu____3090 =
                                    (FStar_Syntax_Util.is_ml_comp c1) &&
                                      (FStar_Syntax_Util.is_ml_comp c2)
                                     in
                                  (match uu____3090 with
                                   | true  -> Some (c2, "both ml")
                                   | uu____3102 -> None)
                               in
                            let subst_c2 reason =
                              match (e1opt, b) with
                              | (Some e,Some x) ->
                                  let uu____3123 =
                                    let uu____3126 =
                                      FStar_Syntax_Subst.subst_comp
                                        [FStar_Syntax_Syntax.NT (x, e)] c2
                                       in
                                    (uu____3126, reason)  in
                                  Some uu____3123
                              | uu____3129 -> aux ()  in
                            let uu____3134 =
                              (FStar_Syntax_Util.is_total_comp c1) &&
                                (FStar_Syntax_Util.is_total_comp c2)
                               in
                            match uu____3134 with
                            | true  -> subst_c2 "both total"
                            | uu____3138 ->
                                let uu____3139 =
                                  (FStar_Syntax_Util.is_tot_or_gtot_comp c1)
                                    &&
                                    (FStar_Syntax_Util.is_tot_or_gtot_comp c2)
                                   in
                                (match uu____3139 with
                                 | true  ->
                                     let uu____3143 =
                                       let uu____3146 =
                                         FStar_Syntax_Syntax.mk_GTotal
                                           (FStar_Syntax_Util.comp_result c2)
                                          in
                                       (uu____3146, "both gtot")  in
                                     Some uu____3143
                                 | uu____3149 ->
                                     (match (e1opt, b) with
                                      | (Some e,Some x) ->
                                          let uu____3159 =
                                            (FStar_Syntax_Util.is_total_comp
                                               c1)
                                              &&
                                              (let uu____3160 =
                                                 FStar_Syntax_Syntax.is_null_bv
                                                   x
                                                  in
                                               Prims.op_Negation uu____3160)
                                             in
                                          (match uu____3159 with
                                           | true  ->
                                               subst_c2 "substituted e"
                                           | uu____3164 -> aux ())
                                      | uu____3165 -> aux ()))
                             in
                          let uu____3170 = try_simplify ()  in
                          match uu____3170 with
                          | Some (c,reason) -> c
                          | None  ->
                              let uu____3180 = lift_and_destruct env c1 c2
                                 in
                              (match uu____3180 with
                               | ((md,a,kwp),(u_t1,t1,wp1),(u_t2,t2,wp2)) ->
                                   let bs =
                                     match b with
                                     | None  ->
                                         let uu____3214 =
                                           FStar_Syntax_Syntax.null_binder t1
                                            in
                                         [uu____3214]
                                     | Some x ->
                                         let uu____3216 =
                                           FStar_Syntax_Syntax.mk_binder x
                                            in
                                         [uu____3216]
                                      in
                                   let mk_lam wp =
                                     FStar_Syntax_Util.abs bs wp
                                       (Some
                                          (FStar_Util.Inr
                                             (FStar_Syntax_Const.effect_Tot_lid,
                                               [FStar_Syntax_Syntax.TOTAL])))
                                      in
                                   let r1 =
                                     (FStar_Syntax_Syntax.mk
                                        (FStar_Syntax_Syntax.Tm_constant
                                           (FStar_Const.Const_range r1)))
                                       None r1
                                      in
                                   let wp_args =
                                     let uu____3243 =
                                       FStar_Syntax_Syntax.as_arg r1  in
                                     let uu____3244 =
                                       let uu____3246 =
                                         FStar_Syntax_Syntax.as_arg t1  in
                                       let uu____3247 =
                                         let uu____3249 =
                                           FStar_Syntax_Syntax.as_arg t2  in
                                         let uu____3250 =
                                           let uu____3252 =
                                             FStar_Syntax_Syntax.as_arg wp1
                                              in
                                           let uu____3253 =
                                             let uu____3255 =
                                               let uu____3256 = mk_lam wp2
                                                  in
                                               FStar_Syntax_Syntax.as_arg
                                                 uu____3256
                                                in
                                             [uu____3255]  in
                                           uu____3252 :: uu____3253  in
                                         uu____3249 :: uu____3250  in
                                       uu____3246 :: uu____3247  in
                                     uu____3243 :: uu____3244  in
                                   let k =
                                     FStar_Syntax_Subst.subst
                                       [FStar_Syntax_Syntax.NT (a, t2)] kwp
                                      in
                                   let wp =
                                     let uu____3261 =
                                       let uu____3262 =
                                         FStar_TypeChecker_Env.inst_effect_fun_with
                                           [u_t1; u_t2] env md
                                           md.FStar_Syntax_Syntax.bind_wp
                                          in
                                       FStar_Syntax_Syntax.mk_Tm_app
                                         uu____3262 wp_args
                                        in
                                     uu____3261 None
                                       t2.FStar_Syntax_Syntax.pos
                                      in
                                   let c = (mk_comp md) u_t2 t2 wp []  in c)))
                     in
                  {
                    FStar_Syntax_Syntax.eff_name = joined_eff;
                    FStar_Syntax_Syntax.res_typ =
                      (lc2.FStar_Syntax_Syntax.res_typ);
                    FStar_Syntax_Syntax.cflags = [];
                    FStar_Syntax_Syntax.comp = bind_it
                  }))
  
let label :
  Prims.string ->
    FStar_Range.range ->
      FStar_Syntax_Syntax.typ ->
        (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
          FStar_Syntax_Syntax.syntax
  =
  fun reason  ->
    fun r  ->
      fun f  ->
        (FStar_Syntax_Syntax.mk
           (FStar_Syntax_Syntax.Tm_meta
              (f, (FStar_Syntax_Syntax.Meta_labeled (reason, r, false)))))
          None f.FStar_Syntax_Syntax.pos
  
let label_opt :
  FStar_TypeChecker_Env.env ->
    (Prims.unit -> Prims.string) Prims.option ->
      FStar_Range.range -> FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.typ
  =
  fun env  ->
    fun reason  ->
      fun r  ->
        fun f  ->
          match reason with
          | None  -> f
          | Some reason ->
              let uu____3311 =
                let uu____3312 = FStar_TypeChecker_Env.should_verify env  in
                FStar_All.pipe_left Prims.op_Negation uu____3312  in
              (match uu____3311 with
               | true  -> f
               | uu____3313 ->
                   let uu____3314 = reason ()  in label uu____3314 r f)
  
let label_guard :
  FStar_Range.range ->
    Prims.string ->
      FStar_TypeChecker_Env.guard_t -> FStar_TypeChecker_Env.guard_t
  =
  fun r  ->
    fun reason  ->
      fun g  ->
        match g.FStar_TypeChecker_Env.guard_f with
        | FStar_TypeChecker_Common.Trivial  -> g
        | FStar_TypeChecker_Common.NonTrivial f ->
            let uu___124_3325 = g  in
            let uu____3326 =
              let uu____3327 = label reason r f  in
              FStar_TypeChecker_Common.NonTrivial uu____3327  in
            {
              FStar_TypeChecker_Env.guard_f = uu____3326;
              FStar_TypeChecker_Env.deferred =
                (uu___124_3325.FStar_TypeChecker_Env.deferred);
              FStar_TypeChecker_Env.univ_ineqs =
                (uu___124_3325.FStar_TypeChecker_Env.univ_ineqs);
              FStar_TypeChecker_Env.implicits =
                (uu___124_3325.FStar_TypeChecker_Env.implicits)
            }
  
let weaken_guard :
  FStar_TypeChecker_Common.guard_formula ->
    FStar_TypeChecker_Common.guard_formula ->
      FStar_TypeChecker_Common.guard_formula
  =
  fun g1  ->
    fun g2  ->
      match (g1, g2) with
      | (FStar_TypeChecker_Common.NonTrivial
         f1,FStar_TypeChecker_Common.NonTrivial f2) ->
          let g = FStar_Syntax_Util.mk_imp f1 f2  in
          FStar_TypeChecker_Common.NonTrivial g
      | uu____3337 -> g2
  
let weaken_precondition :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.lcomp ->
      FStar_TypeChecker_Common.guard_formula -> FStar_Syntax_Syntax.lcomp
  =
  fun env  ->
    fun lc  ->
      fun f  ->
        let weaken uu____3354 =
          let c = lc.FStar_Syntax_Syntax.comp ()  in
          let uu____3358 =
            env.FStar_TypeChecker_Env.lax && (FStar_Options.ml_ish ())  in
          match uu____3358 with
          | true  -> c
          | uu____3361 ->
              (match f with
               | FStar_TypeChecker_Common.Trivial  -> c
               | FStar_TypeChecker_Common.NonTrivial f ->
                   let uu____3365 = FStar_Syntax_Util.is_ml_comp c  in
                   (match uu____3365 with
                    | true  -> c
                    | uu____3368 ->
                        let c =
                          FStar_TypeChecker_Normalize.unfold_effect_abbrev
                            env c
                           in
                        let uu____3370 = destruct_comp c  in
                        (match uu____3370 with
                         | (u_res_t,res_t,wp) ->
                             let md =
                               FStar_TypeChecker_Env.get_effect_decl env
                                 c.FStar_Syntax_Syntax.effect_name
                                in
                             let wp =
                               let uu____3383 =
                                 let uu____3384 =
                                   FStar_TypeChecker_Env.inst_effect_fun_with
                                     [u_res_t] env md
                                     md.FStar_Syntax_Syntax.assume_p
                                    in
                                 let uu____3385 =
                                   let uu____3386 =
                                     FStar_Syntax_Syntax.as_arg res_t  in
                                   let uu____3387 =
                                     let uu____3389 =
                                       FStar_Syntax_Syntax.as_arg f  in
                                     let uu____3390 =
                                       let uu____3392 =
                                         FStar_Syntax_Syntax.as_arg wp  in
                                       [uu____3392]  in
                                     uu____3389 :: uu____3390  in
                                   uu____3386 :: uu____3387  in
                                 FStar_Syntax_Syntax.mk_Tm_app uu____3384
                                   uu____3385
                                  in
                               uu____3383 None wp.FStar_Syntax_Syntax.pos  in
                             (mk_comp md) u_res_t res_t wp
                               c.FStar_Syntax_Syntax.flags)))
           in
        let uu___125_3397 = lc  in
        {
          FStar_Syntax_Syntax.eff_name =
            (uu___125_3397.FStar_Syntax_Syntax.eff_name);
          FStar_Syntax_Syntax.res_typ =
            (uu___125_3397.FStar_Syntax_Syntax.res_typ);
          FStar_Syntax_Syntax.cflags =
            (uu___125_3397.FStar_Syntax_Syntax.cflags);
          FStar_Syntax_Syntax.comp = weaken
        }
  
let strengthen_precondition :
  (Prims.unit -> Prims.string) Prims.option ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term ->
        FStar_Syntax_Syntax.lcomp ->
          FStar_TypeChecker_Env.guard_t ->
            (FStar_Syntax_Syntax.lcomp * FStar_TypeChecker_Env.guard_t)
  =
  fun reason  ->
    fun env  ->
      fun e  ->
        fun lc  ->
          fun g0  ->
            let uu____3424 = FStar_TypeChecker_Rel.is_trivial g0  in
            match uu____3424 with
            | true  -> (lc, g0)
            | uu____3427 ->
                ((let uu____3429 =
                    FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                      FStar_Options.Extreme
                     in
                  match uu____3429 with
                  | true  ->
                      let uu____3430 =
                        FStar_TypeChecker_Normalize.term_to_string env e  in
                      let uu____3431 =
                        FStar_TypeChecker_Rel.guard_to_string env g0  in
                      FStar_Util.print2
                        "+++++++++++++Strengthening pre-condition of term %s with guard %s\n"
                        uu____3430 uu____3431
                  | uu____3432 -> ());
                 (let flags =
                    FStar_All.pipe_right lc.FStar_Syntax_Syntax.cflags
                      (FStar_List.collect
                         (fun uu___92_3437  ->
                            match uu___92_3437 with
                            | FStar_Syntax_Syntax.RETURN 
                              |FStar_Syntax_Syntax.PARTIAL_RETURN  ->
                                [FStar_Syntax_Syntax.PARTIAL_RETURN]
                            | uu____3439 -> []))
                     in
                  let strengthen uu____3445 =
                    let c = lc.FStar_Syntax_Syntax.comp ()  in
                    match env.FStar_TypeChecker_Env.lax with
                    | true  -> c
                    | uu____3451 ->
                        let g0 = FStar_TypeChecker_Rel.simplify_guard env g0
                           in
                        let uu____3453 = FStar_TypeChecker_Rel.guard_form g0
                           in
                        (match uu____3453 with
                         | FStar_TypeChecker_Common.Trivial  -> c
                         | FStar_TypeChecker_Common.NonTrivial f ->
                             let c =
                               let uu____3460 =
                                 (FStar_Syntax_Util.is_pure_or_ghost_comp c)
                                   &&
                                   (let uu____3461 =
                                      FStar_Syntax_Util.is_partial_return c
                                       in
                                    Prims.op_Negation uu____3461)
                                  in
                               match uu____3460 with
                               | true  ->
                                   let x =
                                     FStar_Syntax_Syntax.gen_bv
                                       "strengthen_pre_x" None
                                       (FStar_Syntax_Util.comp_result c)
                                      in
                                   let xret =
                                     let uu____3468 =
                                       let uu____3469 =
                                         FStar_Syntax_Syntax.bv_to_name x  in
                                       return_value env
                                         x.FStar_Syntax_Syntax.sort
                                         uu____3469
                                        in
                                     FStar_Syntax_Util.comp_set_flags
                                       uu____3468
                                       [FStar_Syntax_Syntax.PARTIAL_RETURN]
                                      in
                                   let lc =
                                     bind e.FStar_Syntax_Syntax.pos env
                                       (Some e)
                                       (FStar_Syntax_Util.lcomp_of_comp c)
                                       ((Some x),
                                         (FStar_Syntax_Util.lcomp_of_comp
                                            xret))
                                      in
                                   lc.FStar_Syntax_Syntax.comp ()
                               | uu____3472 -> c  in
                             ((let uu____3474 =
                                 FStar_All.pipe_left
                                   (FStar_TypeChecker_Env.debug env)
                                   FStar_Options.Extreme
                                  in
                               match uu____3474 with
                               | true  ->
                                   let uu____3475 =
                                     FStar_TypeChecker_Normalize.term_to_string
                                       env e
                                      in
                                   let uu____3476 =
                                     FStar_TypeChecker_Normalize.term_to_string
                                       env f
                                      in
                                   FStar_Util.print2
                                     "-------------Strengthening pre-condition of term %s with guard %s\n"
                                     uu____3475 uu____3476
                               | uu____3477 -> ());
                              (let c =
                                 FStar_TypeChecker_Normalize.unfold_effect_abbrev
                                   env c
                                  in
                               let uu____3479 = destruct_comp c  in
                               match uu____3479 with
                               | (u_res_t,res_t,wp) ->
                                   let md =
                                     FStar_TypeChecker_Env.get_effect_decl
                                       env c.FStar_Syntax_Syntax.effect_name
                                      in
                                   let wp =
                                     let uu____3492 =
                                       let uu____3493 =
                                         FStar_TypeChecker_Env.inst_effect_fun_with
                                           [u_res_t] env md
                                           md.FStar_Syntax_Syntax.assert_p
                                          in
                                       let uu____3494 =
                                         let uu____3495 =
                                           FStar_Syntax_Syntax.as_arg res_t
                                            in
                                         let uu____3496 =
                                           let uu____3498 =
                                             let uu____3499 =
                                               let uu____3500 =
                                                 FStar_TypeChecker_Env.get_range
                                                   env
                                                  in
                                               label_opt env reason
                                                 uu____3500 f
                                                in
                                             FStar_All.pipe_left
                                               FStar_Syntax_Syntax.as_arg
                                               uu____3499
                                              in
                                           let uu____3501 =
                                             let uu____3503 =
                                               FStar_Syntax_Syntax.as_arg wp
                                                in
                                             [uu____3503]  in
                                           uu____3498 :: uu____3501  in
                                         uu____3495 :: uu____3496  in
                                       FStar_Syntax_Syntax.mk_Tm_app
                                         uu____3493 uu____3494
                                        in
                                     uu____3492 None
                                       wp.FStar_Syntax_Syntax.pos
                                      in
                                   ((let uu____3509 =
                                       FStar_All.pipe_left
                                         (FStar_TypeChecker_Env.debug env)
                                         FStar_Options.Extreme
                                        in
                                     match uu____3509 with
                                     | true  ->
                                         let uu____3510 =
                                           FStar_Syntax_Print.term_to_string
                                             wp
                                            in
                                         FStar_Util.print1
                                           "-------------Strengthened pre-condition is %s\n"
                                           uu____3510
                                     | uu____3511 -> ());
                                    (let c2 =
                                       (mk_comp md) u_res_t res_t wp flags
                                        in
                                     c2)))))
                     in
                  let uu____3513 =
                    let uu___126_3514 = lc  in
                    let uu____3515 =
                      FStar_TypeChecker_Env.norm_eff_name env
                        lc.FStar_Syntax_Syntax.eff_name
                       in
                    let uu____3516 =
                      let uu____3518 =
                        (FStar_Syntax_Util.is_pure_lcomp lc) &&
                          (let uu____3519 =
                             FStar_Syntax_Util.is_function_typ
                               lc.FStar_Syntax_Syntax.res_typ
                              in
                           FStar_All.pipe_left Prims.op_Negation uu____3519)
                         in
                      match uu____3518 with
                      | true  -> flags
                      | uu____3521 -> []  in
                    {
                      FStar_Syntax_Syntax.eff_name = uu____3515;
                      FStar_Syntax_Syntax.res_typ =
                        (uu___126_3514.FStar_Syntax_Syntax.res_typ);
                      FStar_Syntax_Syntax.cflags = uu____3516;
                      FStar_Syntax_Syntax.comp = strengthen
                    }  in
                  (uu____3513,
                    (let uu___127_3522 = g0  in
                     {
                       FStar_TypeChecker_Env.guard_f =
                         FStar_TypeChecker_Common.Trivial;
                       FStar_TypeChecker_Env.deferred =
                         (uu___127_3522.FStar_TypeChecker_Env.deferred);
                       FStar_TypeChecker_Env.univ_ineqs =
                         (uu___127_3522.FStar_TypeChecker_Env.univ_ineqs);
                       FStar_TypeChecker_Env.implicits =
                         (uu___127_3522.FStar_TypeChecker_Env.implicits)
                     }))))
  
let add_equality_to_post_condition :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.comp ->
      FStar_Syntax_Syntax.typ ->
        (FStar_Syntax_Syntax.comp',Prims.unit) FStar_Syntax_Syntax.syntax
  =
  fun env  ->
    fun comp  ->
      fun res_t  ->
        let md_pure =
          FStar_TypeChecker_Env.get_effect_decl env
            FStar_Syntax_Const.effect_PURE_lid
           in
        let x = FStar_Syntax_Syntax.new_bv None res_t  in
        let y = FStar_Syntax_Syntax.new_bv None res_t  in
        let uu____3537 =
          let uu____3540 = FStar_Syntax_Syntax.bv_to_name x  in
          let uu____3541 = FStar_Syntax_Syntax.bv_to_name y  in
          (uu____3540, uu____3541)  in
        match uu____3537 with
        | (xexp,yexp) ->
            let u_res_t = env.FStar_TypeChecker_Env.universe_of env res_t  in
            let yret =
              let uu____3550 =
                let uu____3551 =
                  FStar_TypeChecker_Env.inst_effect_fun_with [u_res_t] env
                    md_pure md_pure.FStar_Syntax_Syntax.ret_wp
                   in
                let uu____3552 =
                  let uu____3553 = FStar_Syntax_Syntax.as_arg res_t  in
                  let uu____3554 =
                    let uu____3556 = FStar_Syntax_Syntax.as_arg yexp  in
                    [uu____3556]  in
                  uu____3553 :: uu____3554  in
                FStar_Syntax_Syntax.mk_Tm_app uu____3551 uu____3552  in
              uu____3550 None res_t.FStar_Syntax_Syntax.pos  in
            let x_eq_y_yret =
              let uu____3564 =
                let uu____3565 =
                  FStar_TypeChecker_Env.inst_effect_fun_with [u_res_t] env
                    md_pure md_pure.FStar_Syntax_Syntax.assume_p
                   in
                let uu____3566 =
                  let uu____3567 = FStar_Syntax_Syntax.as_arg res_t  in
                  let uu____3568 =
                    let uu____3570 =
                      let uu____3571 =
                        FStar_Syntax_Util.mk_eq res_t res_t xexp yexp  in
                      FStar_All.pipe_left FStar_Syntax_Syntax.as_arg
                        uu____3571
                       in
                    let uu____3572 =
                      let uu____3574 =
                        FStar_All.pipe_left FStar_Syntax_Syntax.as_arg yret
                         in
                      [uu____3574]  in
                    uu____3570 :: uu____3572  in
                  uu____3567 :: uu____3568  in
                FStar_Syntax_Syntax.mk_Tm_app uu____3565 uu____3566  in
              uu____3564 None res_t.FStar_Syntax_Syntax.pos  in
            let forall_y_x_eq_y_yret =
              let uu____3582 =
                let uu____3583 =
                  FStar_TypeChecker_Env.inst_effect_fun_with
                    [u_res_t; u_res_t] env md_pure
                    md_pure.FStar_Syntax_Syntax.close_wp
                   in
                let uu____3584 =
                  let uu____3585 = FStar_Syntax_Syntax.as_arg res_t  in
                  let uu____3586 =
                    let uu____3588 = FStar_Syntax_Syntax.as_arg res_t  in
                    let uu____3589 =
                      let uu____3591 =
                        let uu____3592 =
                          let uu____3593 =
                            let uu____3597 = FStar_Syntax_Syntax.mk_binder y
                               in
                            [uu____3597]  in
                          FStar_Syntax_Util.abs uu____3593 x_eq_y_yret
                            (Some
                               (FStar_Util.Inr
                                  (FStar_Syntax_Const.effect_Tot_lid,
                                    [FStar_Syntax_Syntax.TOTAL])))
                           in
                        FStar_All.pipe_left FStar_Syntax_Syntax.as_arg
                          uu____3592
                         in
                      [uu____3591]  in
                    uu____3588 :: uu____3589  in
                  uu____3585 :: uu____3586  in
                FStar_Syntax_Syntax.mk_Tm_app uu____3583 uu____3584  in
              uu____3582 None res_t.FStar_Syntax_Syntax.pos  in
            let lc2 =
              (mk_comp md_pure) u_res_t res_t forall_y_x_eq_y_yret
                [FStar_Syntax_Syntax.PARTIAL_RETURN]
               in
            let lc =
              let uu____3613 = FStar_TypeChecker_Env.get_range env  in
              bind uu____3613 env None (FStar_Syntax_Util.lcomp_of_comp comp)
                ((Some x), (FStar_Syntax_Util.lcomp_of_comp lc2))
               in
            lc.FStar_Syntax_Syntax.comp ()
  
let ite :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.formula ->
      FStar_Syntax_Syntax.lcomp ->
        FStar_Syntax_Syntax.lcomp -> FStar_Syntax_Syntax.lcomp
  =
  fun env  ->
    fun guard  ->
      fun lcomp_then  ->
        fun lcomp_else  ->
          let joined_eff = join_lcomp env lcomp_then lcomp_else  in
          let comp uu____3631 =
            let uu____3632 =
              env.FStar_TypeChecker_Env.lax && (FStar_Options.ml_ish ())  in
            match uu____3632 with
            | true  ->
                let u_t =
                  env.FStar_TypeChecker_Env.universe_of env
                    lcomp_then.FStar_Syntax_Syntax.res_typ
                   in
                lax_mk_tot_or_comp_l joined_eff u_t
                  lcomp_then.FStar_Syntax_Syntax.res_typ []
            | uu____3634 ->
                let uu____3635 =
                  let uu____3648 = lcomp_then.FStar_Syntax_Syntax.comp ()  in
                  let uu____3649 = lcomp_else.FStar_Syntax_Syntax.comp ()  in
                  lift_and_destruct env uu____3648 uu____3649  in
                (match uu____3635 with
                 | ((md,uu____3651,uu____3652),(u_res_t,res_t,wp_then),
                    (uu____3656,uu____3657,wp_else)) ->
                     let ifthenelse md res_t g wp_t wp_e =
                       let uu____3686 =
                         FStar_Range.union_ranges
                           wp_t.FStar_Syntax_Syntax.pos
                           wp_e.FStar_Syntax_Syntax.pos
                          in
                       let uu____3687 =
                         let uu____3688 =
                           FStar_TypeChecker_Env.inst_effect_fun_with
                             [u_res_t] env md
                             md.FStar_Syntax_Syntax.if_then_else
                            in
                         let uu____3689 =
                           let uu____3690 = FStar_Syntax_Syntax.as_arg res_t
                              in
                           let uu____3691 =
                             let uu____3693 = FStar_Syntax_Syntax.as_arg g
                                in
                             let uu____3694 =
                               let uu____3696 =
                                 FStar_Syntax_Syntax.as_arg wp_t  in
                               let uu____3697 =
                                 let uu____3699 =
                                   FStar_Syntax_Syntax.as_arg wp_e  in
                                 [uu____3699]  in
                               uu____3696 :: uu____3697  in
                             uu____3693 :: uu____3694  in
                           uu____3690 :: uu____3691  in
                         FStar_Syntax_Syntax.mk_Tm_app uu____3688 uu____3689
                          in
                       uu____3687 None uu____3686  in
                     let wp = ifthenelse md res_t guard wp_then wp_else  in
                     let uu____3707 =
                       let uu____3708 = FStar_Options.split_cases ()  in
                       uu____3708 > (Prims.parse_int "0")  in
                     (match uu____3707 with
                      | true  ->
                          let comp = (mk_comp md) u_res_t res_t wp []  in
                          add_equality_to_post_condition env comp res_t
                      | uu____3710 ->
                          let wp =
                            let uu____3714 =
                              let uu____3715 =
                                FStar_TypeChecker_Env.inst_effect_fun_with
                                  [u_res_t] env md
                                  md.FStar_Syntax_Syntax.ite_wp
                                 in
                              let uu____3716 =
                                let uu____3717 =
                                  FStar_Syntax_Syntax.as_arg res_t  in
                                let uu____3718 =
                                  let uu____3720 =
                                    FStar_Syntax_Syntax.as_arg wp  in
                                  [uu____3720]  in
                                uu____3717 :: uu____3718  in
                              FStar_Syntax_Syntax.mk_Tm_app uu____3715
                                uu____3716
                               in
                            uu____3714 None wp.FStar_Syntax_Syntax.pos  in
                          (mk_comp md) u_res_t res_t wp []))
             in
          let uu____3725 =
            join_effects env lcomp_then.FStar_Syntax_Syntax.eff_name
              lcomp_else.FStar_Syntax_Syntax.eff_name
             in
          {
            FStar_Syntax_Syntax.eff_name = uu____3725;
            FStar_Syntax_Syntax.res_typ =
              (lcomp_then.FStar_Syntax_Syntax.res_typ);
            FStar_Syntax_Syntax.cflags = [];
            FStar_Syntax_Syntax.comp = comp
          }
  
let fvar_const :
  FStar_TypeChecker_Env.env -> FStar_Ident.lident -> FStar_Syntax_Syntax.term
  =
  fun env  ->
    fun lid  ->
      let uu____3732 =
        let uu____3733 = FStar_TypeChecker_Env.get_range env  in
        FStar_Ident.set_lid_range lid uu____3733  in
      FStar_Syntax_Syntax.fvar uu____3732 FStar_Syntax_Syntax.Delta_constant
        None
  
let bind_cases :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.typ ->
      (FStar_Syntax_Syntax.formula * FStar_Syntax_Syntax.lcomp) Prims.list ->
        FStar_Syntax_Syntax.lcomp
  =
  fun env  ->
    fun res_t  ->
      fun lcases  ->
        let eff =
          FStar_List.fold_left
            (fun eff  ->
               fun uu____3753  ->
                 match uu____3753 with
                 | (uu____3756,lc) ->
                     join_effects env eff lc.FStar_Syntax_Syntax.eff_name)
            FStar_Syntax_Const.effect_PURE_lid lcases
           in
        let bind_cases uu____3761 =
          let u_res_t = env.FStar_TypeChecker_Env.universe_of env res_t  in
          let uu____3763 =
            env.FStar_TypeChecker_Env.lax && (FStar_Options.ml_ish ())  in
          match uu____3763 with
          | true  -> lax_mk_tot_or_comp_l eff u_res_t res_t []
          | uu____3764 ->
              let ifthenelse md res_t g wp_t wp_e =
                let uu____3783 =
                  FStar_Range.union_ranges wp_t.FStar_Syntax_Syntax.pos
                    wp_e.FStar_Syntax_Syntax.pos
                   in
                let uu____3784 =
                  let uu____3785 =
                    FStar_TypeChecker_Env.inst_effect_fun_with [u_res_t] env
                      md md.FStar_Syntax_Syntax.if_then_else
                     in
                  let uu____3786 =
                    let uu____3787 = FStar_Syntax_Syntax.as_arg res_t  in
                    let uu____3788 =
                      let uu____3790 = FStar_Syntax_Syntax.as_arg g  in
                      let uu____3791 =
                        let uu____3793 = FStar_Syntax_Syntax.as_arg wp_t  in
                        let uu____3794 =
                          let uu____3796 = FStar_Syntax_Syntax.as_arg wp_e
                             in
                          [uu____3796]  in
                        uu____3793 :: uu____3794  in
                      uu____3790 :: uu____3791  in
                    uu____3787 :: uu____3788  in
                  FStar_Syntax_Syntax.mk_Tm_app uu____3785 uu____3786  in
                uu____3784 None uu____3783  in
              let default_case =
                let post_k =
                  let uu____3805 =
                    let uu____3809 = FStar_Syntax_Syntax.null_binder res_t
                       in
                    [uu____3809]  in
                  let uu____3810 =
                    FStar_Syntax_Syntax.mk_Total FStar_Syntax_Util.ktype0  in
                  FStar_Syntax_Util.arrow uu____3805 uu____3810  in
                let kwp =
                  let uu____3816 =
                    let uu____3820 = FStar_Syntax_Syntax.null_binder post_k
                       in
                    [uu____3820]  in
                  let uu____3821 =
                    FStar_Syntax_Syntax.mk_Total FStar_Syntax_Util.ktype0  in
                  FStar_Syntax_Util.arrow uu____3816 uu____3821  in
                let post = FStar_Syntax_Syntax.new_bv None post_k  in
                let wp =
                  let uu____3826 =
                    let uu____3830 = FStar_Syntax_Syntax.mk_binder post  in
                    [uu____3830]  in
                  let uu____3831 =
                    let uu____3832 =
                      let uu____3835 = FStar_TypeChecker_Env.get_range env
                         in
                      label FStar_TypeChecker_Err.exhaustiveness_check
                        uu____3835
                       in
                    let uu____3836 =
                      fvar_const env FStar_Syntax_Const.false_lid  in
                    FStar_All.pipe_left uu____3832 uu____3836  in
                  FStar_Syntax_Util.abs uu____3826 uu____3831
                    (Some
                       (FStar_Util.Inr
                          (FStar_Syntax_Const.effect_Tot_lid,
                            [FStar_Syntax_Syntax.TOTAL])))
                   in
                let md =
                  FStar_TypeChecker_Env.get_effect_decl env
                    FStar_Syntax_Const.effect_PURE_lid
                   in
                (mk_comp md) u_res_t res_t wp []  in
              let comp =
                FStar_List.fold_right
                  (fun uu____3850  ->
                     fun celse  ->
                       match uu____3850 with
                       | (g,cthen) ->
                           let uu____3856 =
                             let uu____3869 =
                               cthen.FStar_Syntax_Syntax.comp ()  in
                             lift_and_destruct env uu____3869 celse  in
                           (match uu____3856 with
                            | ((md,uu____3871,uu____3872),(uu____3873,uu____3874,wp_then),
                               (uu____3876,uu____3877,wp_else)) ->
                                let uu____3888 =
                                  ifthenelse md res_t g wp_then wp_else  in
                                (mk_comp md) u_res_t res_t uu____3888 []))
                  lcases default_case
                 in
              let uu____3889 =
                let uu____3890 = FStar_Options.split_cases ()  in
                uu____3890 > (Prims.parse_int "0")  in
              (match uu____3889 with
               | true  -> add_equality_to_post_condition env comp res_t
               | uu____3891 ->
                   let comp =
                     FStar_TypeChecker_Normalize.comp_to_comp_typ env comp
                      in
                   let md =
                     FStar_TypeChecker_Env.get_effect_decl env
                       comp.FStar_Syntax_Syntax.effect_name
                      in
                   let uu____3894 = destruct_comp comp  in
                   (match uu____3894 with
                    | (uu____3898,uu____3899,wp) ->
                        let wp =
                          let uu____3904 =
                            let uu____3905 =
                              FStar_TypeChecker_Env.inst_effect_fun_with
                                [u_res_t] env md
                                md.FStar_Syntax_Syntax.ite_wp
                               in
                            let uu____3906 =
                              let uu____3907 =
                                FStar_Syntax_Syntax.as_arg res_t  in
                              let uu____3908 =
                                let uu____3910 =
                                  FStar_Syntax_Syntax.as_arg wp  in
                                [uu____3910]  in
                              uu____3907 :: uu____3908  in
                            FStar_Syntax_Syntax.mk_Tm_app uu____3905
                              uu____3906
                             in
                          uu____3904 None wp.FStar_Syntax_Syntax.pos  in
                        (mk_comp md) u_res_t res_t wp []))
           in
        {
          FStar_Syntax_Syntax.eff_name = eff;
          FStar_Syntax_Syntax.res_typ = res_t;
          FStar_Syntax_Syntax.cflags = [];
          FStar_Syntax_Syntax.comp = bind_cases
        }
  
let close_comp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.bv Prims.list ->
      FStar_Syntax_Syntax.lcomp -> FStar_Syntax_Syntax.lcomp
  =
  fun env  ->
    fun bvs  ->
      fun lc  ->
        let close uu____3931 =
          let c = lc.FStar_Syntax_Syntax.comp ()  in
          let uu____3935 = FStar_Syntax_Util.is_ml_comp c  in
          match uu____3935 with
          | true  -> c
          | uu____3938 ->
              let uu____3939 =
                env.FStar_TypeChecker_Env.lax && (FStar_Options.ml_ish ())
                 in
              (match uu____3939 with
               | true  -> c
               | uu____3942 ->
                   let close_wp u_res md res_t bvs wp0 =
                     FStar_List.fold_right
                       (fun x  ->
                          fun wp  ->
                            let bs =
                              let uu____3971 =
                                FStar_Syntax_Syntax.mk_binder x  in
                              [uu____3971]  in
                            let us =
                              let uu____3974 =
                                let uu____3976 =
                                  env.FStar_TypeChecker_Env.universe_of env
                                    x.FStar_Syntax_Syntax.sort
                                   in
                                [uu____3976]  in
                              u_res :: uu____3974  in
                            let wp =
                              FStar_Syntax_Util.abs bs wp
                                (Some
                                   (FStar_Util.Inr
                                      (FStar_Syntax_Const.effect_Tot_lid,
                                        [FStar_Syntax_Syntax.TOTAL])))
                               in
                            let uu____3987 =
                              let uu____3988 =
                                FStar_TypeChecker_Env.inst_effect_fun_with us
                                  env md md.FStar_Syntax_Syntax.close_wp
                                 in
                              let uu____3989 =
                                let uu____3990 =
                                  FStar_Syntax_Syntax.as_arg res_t  in
                                let uu____3991 =
                                  let uu____3993 =
                                    FStar_Syntax_Syntax.as_arg
                                      x.FStar_Syntax_Syntax.sort
                                     in
                                  let uu____3994 =
                                    let uu____3996 =
                                      FStar_Syntax_Syntax.as_arg wp  in
                                    [uu____3996]  in
                                  uu____3993 :: uu____3994  in
                                uu____3990 :: uu____3991  in
                              FStar_Syntax_Syntax.mk_Tm_app uu____3988
                                uu____3989
                               in
                            uu____3987 None wp0.FStar_Syntax_Syntax.pos) bvs
                       wp0
                      in
                   let c =
                     FStar_TypeChecker_Normalize.unfold_effect_abbrev env c
                      in
                   let uu____4002 = destruct_comp c  in
                   (match uu____4002 with
                    | (u_res_t,res_t,wp) ->
                        let md =
                          FStar_TypeChecker_Env.get_effect_decl env
                            c.FStar_Syntax_Syntax.effect_name
                           in
                        let wp = close_wp u_res_t md res_t bvs wp  in
                        (mk_comp md) u_res_t c.FStar_Syntax_Syntax.result_typ
                          wp c.FStar_Syntax_Syntax.flags))
           in
        let uu___128_4013 = lc  in
        {
          FStar_Syntax_Syntax.eff_name =
            (uu___128_4013.FStar_Syntax_Syntax.eff_name);
          FStar_Syntax_Syntax.res_typ =
            (uu___128_4013.FStar_Syntax_Syntax.res_typ);
          FStar_Syntax_Syntax.cflags =
            (uu___128_4013.FStar_Syntax_Syntax.cflags);
          FStar_Syntax_Syntax.comp = close
        }
  
let maybe_assume_result_eq_pure_term :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.lcomp -> FStar_Syntax_Syntax.lcomp
  =
  fun env  ->
    fun e  ->
      fun lc  ->
        let refine uu____4028 =
          let c = lc.FStar_Syntax_Syntax.comp ()  in
          let uu____4032 =
            (let uu____4033 =
               is_pure_or_ghost_effect env lc.FStar_Syntax_Syntax.eff_name
                in
             Prims.op_Negation uu____4033) || env.FStar_TypeChecker_Env.lax
             in
          match uu____4032 with
          | true  -> c
          | uu____4036 ->
              let uu____4037 = FStar_Syntax_Util.is_partial_return c  in
              (match uu____4037 with
               | true  -> c
               | uu____4040 ->
                   let uu____4041 =
                     (FStar_Syntax_Util.is_tot_or_gtot_comp c) &&
                       (let uu____4042 =
                          FStar_TypeChecker_Env.lid_exists env
                            FStar_Syntax_Const.effect_GTot_lid
                           in
                        Prims.op_Negation uu____4042)
                      in
                   (match uu____4041 with
                    | true  ->
                        let uu____4045 =
                          let uu____4046 =
                            FStar_Range.string_of_range
                              e.FStar_Syntax_Syntax.pos
                             in
                          let uu____4047 =
                            FStar_Syntax_Print.term_to_string e  in
                          FStar_Util.format2 "%s: %s\n" uu____4046 uu____4047
                           in
                        failwith uu____4045
                    | uu____4050 ->
                        let c =
                          FStar_TypeChecker_Normalize.unfold_effect_abbrev
                            env c
                           in
                        let t = c.FStar_Syntax_Syntax.result_typ  in
                        let c = FStar_Syntax_Syntax.mk_Comp c  in
                        let x =
                          FStar_Syntax_Syntax.new_bv
                            (Some (t.FStar_Syntax_Syntax.pos)) t
                           in
                        let xexp = FStar_Syntax_Syntax.bv_to_name x  in
                        let ret =
                          let uu____4059 =
                            let uu____4062 = return_value env t xexp  in
                            FStar_Syntax_Util.comp_set_flags uu____4062
                              [FStar_Syntax_Syntax.PARTIAL_RETURN]
                             in
                          FStar_All.pipe_left FStar_Syntax_Util.lcomp_of_comp
                            uu____4059
                           in
                        let eq = FStar_Syntax_Util.mk_eq t t xexp e  in
                        let eq_ret =
                          weaken_precondition env ret
                            (FStar_TypeChecker_Common.NonTrivial eq)
                           in
                        let c =
                          let uu____4076 =
                            let uu____4077 =
                              let uu____4082 =
                                bind e.FStar_Syntax_Syntax.pos env None
                                  (FStar_Syntax_Util.lcomp_of_comp c)
                                  ((Some x), eq_ret)
                                 in
                              uu____4082.FStar_Syntax_Syntax.comp  in
                            uu____4077 ()  in
                          FStar_Syntax_Util.comp_set_flags uu____4076
                            (FStar_Syntax_Syntax.PARTIAL_RETURN ::
                            (FStar_Syntax_Util.comp_flags c))
                           in
                        c))
           in
        let flags =
          let uu____4086 =
            ((let uu____4087 =
                FStar_Syntax_Util.is_function_typ
                  lc.FStar_Syntax_Syntax.res_typ
                 in
              Prims.op_Negation uu____4087) &&
               (FStar_Syntax_Util.is_pure_or_ghost_lcomp lc))
              &&
              (let uu____4088 = FStar_Syntax_Util.is_lcomp_partial_return lc
                  in
               Prims.op_Negation uu____4088)
             in
          match uu____4086 with
          | true  -> FStar_Syntax_Syntax.PARTIAL_RETURN ::
              (lc.FStar_Syntax_Syntax.cflags)
          | uu____4090 -> lc.FStar_Syntax_Syntax.cflags  in
        let uu___129_4091 = lc  in
        {
          FStar_Syntax_Syntax.eff_name =
            (uu___129_4091.FStar_Syntax_Syntax.eff_name);
          FStar_Syntax_Syntax.res_typ =
            (uu___129_4091.FStar_Syntax_Syntax.res_typ);
          FStar_Syntax_Syntax.cflags = flags;
          FStar_Syntax_Syntax.comp = refine
        }
  
let check_comp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.comp ->
        FStar_Syntax_Syntax.comp ->
          (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.comp *
            FStar_TypeChecker_Env.guard_t)
  =
  fun env  ->
    fun e  ->
      fun c  ->
        fun c'  ->
          let uu____4110 = FStar_TypeChecker_Rel.sub_comp env c c'  in
          match uu____4110 with
          | None  ->
              let uu____4115 =
                let uu____4116 =
                  let uu____4119 =
                    FStar_TypeChecker_Err.computed_computation_type_does_not_match_annotation
                      env e c c'
                     in
                  let uu____4120 = FStar_TypeChecker_Env.get_range env  in
                  (uu____4119, uu____4120)  in
                FStar_Errors.Error uu____4116  in
              Prims.raise uu____4115
          | Some g -> (e, c', g)
  
let maybe_coerce_bool_to_type :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.lcomp ->
        FStar_Syntax_Syntax.term ->
          (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.lcomp)
  =
  fun env  ->
    fun e  ->
      fun lc  ->
        fun t  ->
          let uu____4141 =
            let uu____4142 = FStar_Syntax_Subst.compress t  in
            uu____4142.FStar_Syntax_Syntax.n  in
          match uu____4141 with
          | FStar_Syntax_Syntax.Tm_type uu____4147 ->
              let uu____4148 =
                let uu____4149 =
                  FStar_Syntax_Subst.compress lc.FStar_Syntax_Syntax.res_typ
                   in
                uu____4149.FStar_Syntax_Syntax.n  in
              (match uu____4148 with
               | FStar_Syntax_Syntax.Tm_fvar fv when
                   FStar_Syntax_Syntax.fv_eq_lid fv
                     FStar_Syntax_Const.bool_lid
                   ->
                   let uu____4155 =
                     FStar_TypeChecker_Env.lookup_lid env
                       FStar_Syntax_Const.b2t_lid
                      in
                   let b2t =
                     FStar_Syntax_Syntax.fvar
                       (FStar_Ident.set_lid_range FStar_Syntax_Const.b2t_lid
                          e.FStar_Syntax_Syntax.pos)
                       (FStar_Syntax_Syntax.Delta_defined_at_level
                          (Prims.parse_int "1")) None
                      in
                   let lc =
                     let uu____4160 =
                       let uu____4161 =
                         let uu____4162 =
                           FStar_Syntax_Syntax.mk_Total
                             FStar_Syntax_Util.ktype0
                            in
                         FStar_All.pipe_left FStar_Syntax_Util.lcomp_of_comp
                           uu____4162
                          in
                       (None, uu____4161)  in
                     bind e.FStar_Syntax_Syntax.pos env (Some e) lc
                       uu____4160
                      in
                   let e =
                     let uu____4171 =
                       let uu____4172 =
                         let uu____4173 = FStar_Syntax_Syntax.as_arg e  in
                         [uu____4173]  in
                       FStar_Syntax_Syntax.mk_Tm_app b2t uu____4172  in
                     uu____4171
                       (Some (FStar_Syntax_Util.ktype0.FStar_Syntax_Syntax.n))
                       e.FStar_Syntax_Syntax.pos
                      in
                   (e, lc)
               | uu____4180 -> (e, lc))
          | uu____4181 -> (e, lc)
  
let weaken_result_typ :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.lcomp ->
        FStar_Syntax_Syntax.typ ->
          (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.lcomp *
            FStar_TypeChecker_Env.guard_t)
  =
  fun env  ->
    fun e  ->
      fun lc  ->
        fun t  ->
          let gopt =
            match env.FStar_TypeChecker_Env.use_eq with
            | true  ->
                let uu____4207 =
                  FStar_TypeChecker_Rel.try_teq env
                    lc.FStar_Syntax_Syntax.res_typ t
                   in
                (uu____4207, false)
            | uu____4210 ->
                let uu____4211 =
                  FStar_TypeChecker_Rel.try_subtype env
                    lc.FStar_Syntax_Syntax.res_typ t
                   in
                (uu____4211, true)
             in
          match gopt with
          | (None ,uu____4217) ->
              (FStar_TypeChecker_Rel.subtype_fail env e
                 lc.FStar_Syntax_Syntax.res_typ t;
               (e,
                 ((let uu___130_4220 = lc  in
                   {
                     FStar_Syntax_Syntax.eff_name =
                       (uu___130_4220.FStar_Syntax_Syntax.eff_name);
                     FStar_Syntax_Syntax.res_typ = t;
                     FStar_Syntax_Syntax.cflags =
                       (uu___130_4220.FStar_Syntax_Syntax.cflags);
                     FStar_Syntax_Syntax.comp =
                       (uu___130_4220.FStar_Syntax_Syntax.comp)
                   })), FStar_TypeChecker_Rel.trivial_guard))
          | (Some g,apply_guard) ->
              let uu____4224 = FStar_TypeChecker_Rel.guard_form g  in
              (match uu____4224 with
               | FStar_TypeChecker_Common.Trivial  ->
                   let lc =
                     let uu___131_4229 = lc  in
                     {
                       FStar_Syntax_Syntax.eff_name =
                         (uu___131_4229.FStar_Syntax_Syntax.eff_name);
                       FStar_Syntax_Syntax.res_typ = t;
                       FStar_Syntax_Syntax.cflags =
                         (uu___131_4229.FStar_Syntax_Syntax.cflags);
                       FStar_Syntax_Syntax.comp =
                         (uu___131_4229.FStar_Syntax_Syntax.comp)
                     }  in
                   (e, lc, g)
               | FStar_TypeChecker_Common.NonTrivial f ->
                   let g =
                     let uu___132_4232 = g  in
                     {
                       FStar_TypeChecker_Env.guard_f =
                         FStar_TypeChecker_Common.Trivial;
                       FStar_TypeChecker_Env.deferred =
                         (uu___132_4232.FStar_TypeChecker_Env.deferred);
                       FStar_TypeChecker_Env.univ_ineqs =
                         (uu___132_4232.FStar_TypeChecker_Env.univ_ineqs);
                       FStar_TypeChecker_Env.implicits =
                         (uu___132_4232.FStar_TypeChecker_Env.implicits)
                     }  in
                   let strengthen uu____4238 =
                     let uu____4239 =
                       env.FStar_TypeChecker_Env.lax &&
                         (FStar_Options.ml_ish ())
                        in
                     match uu____4239 with
                     | true  -> lc.FStar_Syntax_Syntax.comp ()
                     | uu____4242 ->
                         let f =
                           FStar_TypeChecker_Normalize.normalize
                             [FStar_TypeChecker_Normalize.Beta;
                             FStar_TypeChecker_Normalize.Eager_unfolding;
                             FStar_TypeChecker_Normalize.Simplify] env f
                            in
                         let uu____4244 =
                           let uu____4245 = FStar_Syntax_Subst.compress f  in
                           uu____4245.FStar_Syntax_Syntax.n  in
                         (match uu____4244 with
                          | FStar_Syntax_Syntax.Tm_abs
                              (uu____4250,{
                                            FStar_Syntax_Syntax.n =
                                              FStar_Syntax_Syntax.Tm_fvar fv;
                                            FStar_Syntax_Syntax.tk =
                                              uu____4252;
                                            FStar_Syntax_Syntax.pos =
                                              uu____4253;
                                            FStar_Syntax_Syntax.vars =
                                              uu____4254;_},uu____4255)
                              when
                              FStar_Syntax_Syntax.fv_eq_lid fv
                                FStar_Syntax_Const.true_lid
                              ->
                              let lc =
                                let uu___133_4279 = lc  in
                                {
                                  FStar_Syntax_Syntax.eff_name =
                                    (uu___133_4279.FStar_Syntax_Syntax.eff_name);
                                  FStar_Syntax_Syntax.res_typ = t;
                                  FStar_Syntax_Syntax.cflags =
                                    (uu___133_4279.FStar_Syntax_Syntax.cflags);
                                  FStar_Syntax_Syntax.comp =
                                    (uu___133_4279.FStar_Syntax_Syntax.comp)
                                }  in
                              lc.FStar_Syntax_Syntax.comp ()
                          | uu____4280 ->
                              let c = lc.FStar_Syntax_Syntax.comp ()  in
                              ((let uu____4285 =
                                  FStar_All.pipe_left
                                    (FStar_TypeChecker_Env.debug env)
                                    FStar_Options.Extreme
                                   in
                                match uu____4285 with
                                | true  ->
                                    let uu____4286 =
                                      FStar_TypeChecker_Normalize.term_to_string
                                        env lc.FStar_Syntax_Syntax.res_typ
                                       in
                                    let uu____4287 =
                                      FStar_TypeChecker_Normalize.term_to_string
                                        env t
                                       in
                                    let uu____4288 =
                                      FStar_TypeChecker_Normalize.comp_to_string
                                        env c
                                       in
                                    let uu____4289 =
                                      FStar_TypeChecker_Normalize.term_to_string
                                        env f
                                       in
                                    FStar_Util.print4
                                      "Weakened from %s to %s\nStrengthening %s with guard %s\n"
                                      uu____4286 uu____4287 uu____4288
                                      uu____4289
                                | uu____4290 -> ());
                               (let ct =
                                  FStar_TypeChecker_Normalize.unfold_effect_abbrev
                                    env c
                                   in
                                let uu____4292 =
                                  FStar_TypeChecker_Env.wp_signature env
                                    FStar_Syntax_Const.effect_PURE_lid
                                   in
                                match uu____4292 with
                                | (a,kwp) ->
                                    let k =
                                      FStar_Syntax_Subst.subst
                                        [FStar_Syntax_Syntax.NT (a, t)] kwp
                                       in
                                    let md =
                                      FStar_TypeChecker_Env.get_effect_decl
                                        env
                                        ct.FStar_Syntax_Syntax.effect_name
                                       in
                                    let x =
                                      FStar_Syntax_Syntax.new_bv
                                        (Some (t.FStar_Syntax_Syntax.pos)) t
                                       in
                                    let xexp =
                                      FStar_Syntax_Syntax.bv_to_name x  in
                                    let uu____4303 = destruct_comp ct  in
                                    (match uu____4303 with
                                     | (u_t,uu____4310,uu____4311) ->
                                         let wp =
                                           let uu____4315 =
                                             let uu____4316 =
                                               FStar_TypeChecker_Env.inst_effect_fun_with
                                                 [u_t] env md
                                                 md.FStar_Syntax_Syntax.ret_wp
                                                in
                                             let uu____4317 =
                                               let uu____4318 =
                                                 FStar_Syntax_Syntax.as_arg t
                                                  in
                                               let uu____4319 =
                                                 let uu____4321 =
                                                   FStar_Syntax_Syntax.as_arg
                                                     xexp
                                                    in
                                                 [uu____4321]  in
                                               uu____4318 :: uu____4319  in
                                             FStar_Syntax_Syntax.mk_Tm_app
                                               uu____4316 uu____4317
                                              in
                                           uu____4315
                                             (Some (k.FStar_Syntax_Syntax.n))
                                             xexp.FStar_Syntax_Syntax.pos
                                            in
                                         let cret =
                                           let uu____4327 =
                                             (mk_comp md) u_t t wp
                                               [FStar_Syntax_Syntax.RETURN]
                                              in
                                           FStar_All.pipe_left
                                             FStar_Syntax_Util.lcomp_of_comp
                                             uu____4327
                                            in
                                         let guard =
                                           match apply_guard with
                                           | true  ->
                                               let uu____4337 =
                                                 let uu____4338 =
                                                   let uu____4339 =
                                                     FStar_Syntax_Syntax.as_arg
                                                       xexp
                                                      in
                                                   [uu____4339]  in
                                                 FStar_Syntax_Syntax.mk_Tm_app
                                                   f uu____4338
                                                  in
                                               uu____4337
                                                 (Some
                                                    (FStar_Syntax_Util.ktype0.FStar_Syntax_Syntax.n))
                                                 f.FStar_Syntax_Syntax.pos
                                           | uu____4344 -> f  in
                                         let uu____4345 =
                                           let uu____4348 =
                                             FStar_All.pipe_left
                                               (fun _0_28  -> Some _0_28)
                                               (FStar_TypeChecker_Err.subtyping_failed
                                                  env
                                                  lc.FStar_Syntax_Syntax.res_typ
                                                  t)
                                              in
                                           let uu____4359 =
                                             FStar_TypeChecker_Env.set_range
                                               env e.FStar_Syntax_Syntax.pos
                                              in
                                           let uu____4360 =
                                             FStar_All.pipe_left
                                               FStar_TypeChecker_Rel.guard_of_guard_formula
                                               (FStar_TypeChecker_Common.NonTrivial
                                                  guard)
                                              in
                                           strengthen_precondition uu____4348
                                             uu____4359 e cret uu____4360
                                            in
                                         (match uu____4345 with
                                          | (eq_ret,_trivial_so_ok_to_discard)
                                              ->
                                              let x =
                                                let uu___134_4366 = x  in
                                                {
                                                  FStar_Syntax_Syntax.ppname
                                                    =
                                                    (uu___134_4366.FStar_Syntax_Syntax.ppname);
                                                  FStar_Syntax_Syntax.index =
                                                    (uu___134_4366.FStar_Syntax_Syntax.index);
                                                  FStar_Syntax_Syntax.sort =
                                                    (lc.FStar_Syntax_Syntax.res_typ)
                                                }  in
                                              let c =
                                                let uu____4368 =
                                                  let uu____4369 =
                                                    FStar_Syntax_Syntax.mk_Comp
                                                      ct
                                                     in
                                                  FStar_All.pipe_left
                                                    FStar_Syntax_Util.lcomp_of_comp
                                                    uu____4369
                                                   in
                                                bind
                                                  e.FStar_Syntax_Syntax.pos
                                                  env (Some e) uu____4368
                                                  ((Some x), eq_ret)
                                                 in
                                              let c =
                                                c.FStar_Syntax_Syntax.comp ()
                                                 in
                                              ((let uu____4379 =
                                                  FStar_All.pipe_left
                                                    (FStar_TypeChecker_Env.debug
                                                       env)
                                                    FStar_Options.Extreme
                                                   in
                                                match uu____4379 with
                                                | true  ->
                                                    let uu____4380 =
                                                      FStar_TypeChecker_Normalize.comp_to_string
                                                        env c
                                                       in
                                                    FStar_Util.print1
                                                      "Strengthened to %s\n"
                                                      uu____4380
                                                | uu____4381 -> ());
                                               c))))))
                      in
                   let flags =
                     FStar_All.pipe_right lc.FStar_Syntax_Syntax.cflags
                       (FStar_List.collect
                          (fun uu___93_4386  ->
                             match uu___93_4386 with
                             | FStar_Syntax_Syntax.RETURN 
                               |FStar_Syntax_Syntax.PARTIAL_RETURN  ->
                                 [FStar_Syntax_Syntax.PARTIAL_RETURN]
                             | FStar_Syntax_Syntax.CPS  ->
                                 [FStar_Syntax_Syntax.CPS]
                             | uu____4388 -> []))
                      in
                   let lc =
                     let uu___135_4390 = lc  in
                     let uu____4391 =
                       FStar_TypeChecker_Env.norm_eff_name env
                         lc.FStar_Syntax_Syntax.eff_name
                        in
                     {
                       FStar_Syntax_Syntax.eff_name = uu____4391;
                       FStar_Syntax_Syntax.res_typ = t;
                       FStar_Syntax_Syntax.cflags = flags;
                       FStar_Syntax_Syntax.comp = strengthen
                     }  in
                   let g =
                     let uu___136_4393 = g  in
                     {
                       FStar_TypeChecker_Env.guard_f =
                         FStar_TypeChecker_Common.Trivial;
                       FStar_TypeChecker_Env.deferred =
                         (uu___136_4393.FStar_TypeChecker_Env.deferred);
                       FStar_TypeChecker_Env.univ_ineqs =
                         (uu___136_4393.FStar_TypeChecker_Env.univ_ineqs);
                       FStar_TypeChecker_Env.implicits =
                         (uu___136_4393.FStar_TypeChecker_Env.implicits)
                     }  in
                   (e, lc, g))
  
let pure_or_ghost_pre_and_post :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.comp ->
      (FStar_Syntax_Syntax.typ Prims.option * FStar_Syntax_Syntax.typ)
  =
  fun env  ->
    fun comp  ->
      let mk_post_type res_t ens =
        let x = FStar_Syntax_Syntax.new_bv None res_t  in
        let uu____4413 =
          let uu____4414 =
            let uu____4415 =
              let uu____4416 =
                let uu____4417 = FStar_Syntax_Syntax.bv_to_name x  in
                FStar_Syntax_Syntax.as_arg uu____4417  in
              [uu____4416]  in
            FStar_Syntax_Syntax.mk_Tm_app ens uu____4415  in
          uu____4414 None res_t.FStar_Syntax_Syntax.pos  in
        FStar_Syntax_Util.refine x uu____4413  in
      let norm t =
        FStar_TypeChecker_Normalize.normalize
          [FStar_TypeChecker_Normalize.Beta;
          FStar_TypeChecker_Normalize.Eager_unfolding;
          FStar_TypeChecker_Normalize.EraseUniverses] env t
         in
      let uu____4426 = FStar_Syntax_Util.is_tot_or_gtot_comp comp  in
      match uu____4426 with
      | true  -> (None, (FStar_Syntax_Util.comp_result comp))
      | uu____4433 ->
          (match comp.FStar_Syntax_Syntax.n with
           | FStar_Syntax_Syntax.GTotal _|FStar_Syntax_Syntax.Total _ ->
               failwith "Impossible"
           | FStar_Syntax_Syntax.Comp ct ->
               (match (FStar_Ident.lid_equals
                         ct.FStar_Syntax_Syntax.effect_name
                         FStar_Syntax_Const.effect_Pure_lid)
                        ||
                        (FStar_Ident.lid_equals
                           ct.FStar_Syntax_Syntax.effect_name
                           FStar_Syntax_Const.effect_Ghost_lid)
                with
                | true  ->
                    (match ct.FStar_Syntax_Syntax.effect_args with
                     | (req,uu____4450)::(ens,uu____4452)::uu____4453 ->
                         let uu____4475 =
                           let uu____4477 = norm req  in Some uu____4477  in
                         let uu____4478 =
                           let uu____4479 =
                             mk_post_type ct.FStar_Syntax_Syntax.result_typ
                               ens
                              in
                           FStar_All.pipe_left norm uu____4479  in
                         (uu____4475, uu____4478)
                     | uu____4481 ->
                         let uu____4487 =
                           let uu____4488 =
                             let uu____4491 =
                               let uu____4492 =
                                 FStar_Syntax_Print.comp_to_string comp  in
                               FStar_Util.format1
                                 "Effect constructor is not fully applied; got %s"
                                 uu____4492
                                in
                             (uu____4491, (comp.FStar_Syntax_Syntax.pos))  in
                           FStar_Errors.Error uu____4488  in
                         Prims.raise uu____4487)
                | uu____4496 ->
                    let ct =
                      FStar_TypeChecker_Normalize.unfold_effect_abbrev env
                        comp
                       in
                    (match ct.FStar_Syntax_Syntax.effect_args with
                     | (wp,uu____4502)::uu____4503 ->
                         let uu____4517 =
                           FStar_TypeChecker_Env.lookup_lid env
                             FStar_Syntax_Const.as_requires
                            in
                         (match uu____4517 with
                          | (us_r,uu____4524) ->
                              let uu____4525 =
                                FStar_TypeChecker_Env.lookup_lid env
                                  FStar_Syntax_Const.as_ensures
                                 in
                              (match uu____4525 with
                               | (us_e,uu____4532) ->
                                   let r =
                                     (ct.FStar_Syntax_Syntax.result_typ).FStar_Syntax_Syntax.pos
                                      in
                                   let as_req =
                                     let uu____4535 =
                                       FStar_Syntax_Syntax.fvar
                                         (FStar_Ident.set_lid_range
                                            FStar_Syntax_Const.as_requires r)
                                         FStar_Syntax_Syntax.Delta_equational
                                         None
                                        in
                                     FStar_Syntax_Syntax.mk_Tm_uinst
                                       uu____4535 us_r
                                      in
                                   let as_ens =
                                     let uu____4537 =
                                       FStar_Syntax_Syntax.fvar
                                         (FStar_Ident.set_lid_range
                                            FStar_Syntax_Const.as_ensures r)
                                         FStar_Syntax_Syntax.Delta_equational
                                         None
                                        in
                                     FStar_Syntax_Syntax.mk_Tm_uinst
                                       uu____4537 us_e
                                      in
                                   let req =
                                     let uu____4541 =
                                       let uu____4542 =
                                         let uu____4543 =
                                           let uu____4550 =
                                             FStar_Syntax_Syntax.as_arg wp
                                              in
                                           [uu____4550]  in
                                         ((ct.FStar_Syntax_Syntax.result_typ),
                                           (Some FStar_Syntax_Syntax.imp_tag))
                                           :: uu____4543
                                          in
                                       FStar_Syntax_Syntax.mk_Tm_app as_req
                                         uu____4542
                                        in
                                     uu____4541
                                       (Some
                                          (FStar_Syntax_Util.ktype0.FStar_Syntax_Syntax.n))
                                       (ct.FStar_Syntax_Syntax.result_typ).FStar_Syntax_Syntax.pos
                                      in
                                   let ens =
                                     let uu____4566 =
                                       let uu____4567 =
                                         let uu____4568 =
                                           let uu____4575 =
                                             FStar_Syntax_Syntax.as_arg wp
                                              in
                                           [uu____4575]  in
                                         ((ct.FStar_Syntax_Syntax.result_typ),
                                           (Some FStar_Syntax_Syntax.imp_tag))
                                           :: uu____4568
                                          in
                                       FStar_Syntax_Syntax.mk_Tm_app as_ens
                                         uu____4567
                                        in
                                     uu____4566 None
                                       (ct.FStar_Syntax_Syntax.result_typ).FStar_Syntax_Syntax.pos
                                      in
                                   let uu____4588 =
                                     let uu____4590 = norm req  in
                                     Some uu____4590  in
                                   let uu____4591 =
                                     let uu____4592 =
                                       mk_post_type
                                         ct.FStar_Syntax_Syntax.result_typ
                                         ens
                                        in
                                     norm uu____4592  in
                                   (uu____4588, uu____4591)))
                     | uu____4594 -> failwith "Impossible")))
  
let maybe_instantiate :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.typ ->
        (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.typ *
          FStar_TypeChecker_Env.guard_t)
  =
  fun env  ->
    fun e  ->
      fun t  ->
        let torig = FStar_Syntax_Subst.compress t  in
        match Prims.op_Negation env.FStar_TypeChecker_Env.instantiate_imp
        with
        | true  -> (e, torig, FStar_TypeChecker_Rel.trivial_guard)
        | uu____4619 ->
            let number_of_implicits t =
              let uu____4624 = FStar_Syntax_Util.arrow_formals t  in
              match uu____4624 with
              | (formals,uu____4633) ->
                  let n_implicits =
                    let uu____4645 =
                      FStar_All.pipe_right formals
                        (FStar_Util.prefix_until
                           (fun uu____4682  ->
                              match uu____4682 with
                              | (uu____4686,imp) ->
                                  (imp = None) ||
                                    (imp =
                                       (Some FStar_Syntax_Syntax.Equality))))
                       in
                    match uu____4645 with
                    | None  -> FStar_List.length formals
                    | Some (implicits,_first_explicit,_rest) ->
                        FStar_List.length implicits
                     in
                  n_implicits
               in
            let inst_n_binders t =
              let uu____4758 = FStar_TypeChecker_Env.expected_typ env  in
              match uu____4758 with
              | None  -> None
              | Some expected_t ->
                  let n_expected = number_of_implicits expected_t  in
                  let n_available = number_of_implicits t  in
                  (match n_available < n_expected with
                   | true  ->
                       let uu____4772 =
                         let uu____4773 =
                           let uu____4776 =
                             let uu____4777 =
                               FStar_Util.string_of_int n_expected  in
                             let uu____4781 =
                               FStar_Syntax_Print.term_to_string e  in
                             let uu____4782 =
                               FStar_Util.string_of_int n_available  in
                             FStar_Util.format3
                               "Expected a term with %s implicit arguments, but %s has only %s"
                               uu____4777 uu____4781 uu____4782
                              in
                           let uu____4786 =
                             FStar_TypeChecker_Env.get_range env  in
                           (uu____4776, uu____4786)  in
                         FStar_Errors.Error uu____4773  in
                       Prims.raise uu____4772
                   | uu____4788 -> Some (n_available - n_expected))
               in
            let decr_inst uu___94_4799 =
              match uu___94_4799 with
              | None  -> None
              | Some i -> Some (i - (Prims.parse_int "1"))  in
            (match torig.FStar_Syntax_Syntax.n with
             | FStar_Syntax_Syntax.Tm_arrow (bs,c) ->
                 let uu____4818 = FStar_Syntax_Subst.open_comp bs c  in
                 (match uu____4818 with
                  | (bs,c) ->
                      let rec aux subst inst_n bs =
                        match (inst_n, bs) with
                        | (Some _0_29,uu____4879) when
                            _0_29 = (Prims.parse_int "0") ->
                            ([], bs, subst,
                              FStar_TypeChecker_Rel.trivial_guard)
                        | (uu____4901,(x,Some (FStar_Syntax_Syntax.Implicit
                                       dot))::rest)
                            ->
                            let t =
                              FStar_Syntax_Subst.subst subst
                                x.FStar_Syntax_Syntax.sort
                               in
                            let uu____4920 =
                              new_implicit_var
                                "Instantiation of implicit argument"
                                e.FStar_Syntax_Syntax.pos env t
                               in
                            (match uu____4920 with
                             | (v,uu____4941,g) ->
                                 let subst = (FStar_Syntax_Syntax.NT (x, v))
                                   :: subst  in
                                 let uu____4951 =
                                   aux subst (decr_inst inst_n) rest  in
                                 (match uu____4951 with
                                  | (args,bs,subst,g') ->
                                      let uu____5000 =
                                        FStar_TypeChecker_Rel.conj_guard g g'
                                         in
                                      (((v,
                                          (Some
                                             (FStar_Syntax_Syntax.Implicit
                                                dot))) :: args), bs, subst,
                                        uu____5000)))
                        | (uu____5014,bs) ->
                            ([], bs, subst,
                              FStar_TypeChecker_Rel.trivial_guard)
                         in
                      let uu____5038 =
                        let uu____5052 = inst_n_binders t  in
                        aux [] uu____5052 bs  in
                      (match uu____5038 with
                       | (args,bs,subst,guard) ->
                           (match (args, bs) with
                            | ([],uu____5090) -> (e, torig, guard)
                            | (uu____5106,[]) when
                                let uu____5122 =
                                  FStar_Syntax_Util.is_total_comp c  in
                                Prims.op_Negation uu____5122 ->
                                (e, torig,
                                  FStar_TypeChecker_Rel.trivial_guard)
                            | uu____5123 ->
                                let t =
                                  match bs with
                                  | [] -> FStar_Syntax_Util.comp_result c
                                  | uu____5142 ->
                                      FStar_Syntax_Util.arrow bs c
                                   in
                                let t = FStar_Syntax_Subst.subst subst t  in
                                let e =
                                  (FStar_Syntax_Syntax.mk_Tm_app e args)
                                    (Some (t.FStar_Syntax_Syntax.n))
                                    e.FStar_Syntax_Syntax.pos
                                   in
                                (e, t, guard))))
             | uu____5157 -> (e, t, FStar_TypeChecker_Rel.trivial_guard))
  
let string_of_univs univs =
  let uu____5169 =
    let uu____5171 = FStar_Util.set_elements univs  in
    FStar_All.pipe_right uu____5171
      (FStar_List.map
         (fun u  ->
            let uu____5181 = FStar_Unionfind.uvar_id u  in
            FStar_All.pipe_right uu____5181 FStar_Util.string_of_int))
     in
  FStar_All.pipe_right uu____5169 (FStar_String.concat ", ") 
let gen_univs :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.universe_uvar FStar_Util.set ->
      FStar_Syntax_Syntax.univ_name Prims.list
  =
  fun env  ->
    fun x  ->
      let uu____5193 = FStar_Util.set_is_empty x  in
      match uu____5193 with
      | true  -> []
      | uu____5195 ->
          let s =
            let uu____5198 =
              let uu____5200 = FStar_TypeChecker_Env.univ_vars env  in
              FStar_Util.set_difference x uu____5200  in
            FStar_All.pipe_right uu____5198 FStar_Util.set_elements  in
          ((let uu____5205 =
              FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                (FStar_Options.Other "Gen")
               in
            match uu____5205 with
            | true  ->
                let uu____5206 =
                  let uu____5207 = FStar_TypeChecker_Env.univ_vars env  in
                  string_of_univs uu____5207  in
                FStar_Util.print1 "univ_vars in env: %s\n" uu____5206
            | uu____5212 -> ());
           (let r =
              let uu____5215 = FStar_TypeChecker_Env.get_range env  in
              Some uu____5215  in
            let u_names =
              FStar_All.pipe_right s
                (FStar_List.map
                   (fun u  ->
                      let u_name = FStar_Syntax_Syntax.new_univ_name r  in
                      (let uu____5227 =
                         FStar_All.pipe_left
                           (FStar_TypeChecker_Env.debug env)
                           (FStar_Options.Other "Gen")
                          in
                       match uu____5227 with
                       | true  ->
                           let uu____5228 =
                             let uu____5229 = FStar_Unionfind.uvar_id u  in
                             FStar_All.pipe_left FStar_Util.string_of_int
                               uu____5229
                              in
                           let uu____5231 =
                             FStar_Syntax_Print.univ_to_string
                               (FStar_Syntax_Syntax.U_unif u)
                              in
                           let uu____5232 =
                             FStar_Syntax_Print.univ_to_string
                               (FStar_Syntax_Syntax.U_name u_name)
                              in
                           FStar_Util.print3 "Setting ?%s (%s) to %s\n"
                             uu____5228 uu____5231 uu____5232
                       | uu____5233 -> ());
                      FStar_Unionfind.change u
                        (Some (FStar_Syntax_Syntax.U_name u_name));
                      u_name))
               in
            u_names))
  
let gather_free_univnames :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.univ_name Prims.list
  =
  fun env  ->
    fun t  ->
      let ctx_univnames = FStar_TypeChecker_Env.univnames env  in
      let tm_univnames = FStar_Syntax_Free.univnames t  in
      let univnames =
        let uu____5250 =
          FStar_Util.fifo_set_difference tm_univnames ctx_univnames  in
        FStar_All.pipe_right uu____5250 FStar_Util.fifo_set_elements  in
      univnames
  
let maybe_set_tk ts uu___95_5277 =
  match uu___95_5277 with
  | None  -> ts
  | Some t ->
      let t = FStar_Syntax_Syntax.mk t None FStar_Range.dummyRange  in
      let t = FStar_Syntax_Subst.close_univ_vars (Prims.fst ts) t  in
      (FStar_ST.write (Prims.snd ts).FStar_Syntax_Syntax.tk
         (Some (t.FStar_Syntax_Syntax.n));
       ts)
  
let check_universe_generalization :
  FStar_Syntax_Syntax.univ_name Prims.list ->
    FStar_Syntax_Syntax.univ_name Prims.list ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.univ_name Prims.list
  =
  fun explicit_univ_names  ->
    fun generalized_univ_names  ->
      fun t  ->
        match (explicit_univ_names, generalized_univ_names) with
        | ([],uu____5318) -> generalized_univ_names
        | (uu____5322,[]) -> explicit_univ_names
        | uu____5326 ->
            let uu____5331 =
              let uu____5332 =
                let uu____5335 =
                  let uu____5336 = FStar_Syntax_Print.term_to_string t  in
                  Prims.strcat
                    "Generalized universe in a term containing explicit universe annotation : "
                    uu____5336
                   in
                (uu____5335, (t.FStar_Syntax_Syntax.pos))  in
              FStar_Errors.Error uu____5332  in
            Prims.raise uu____5331
  
let generalize_universes :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.univ_names *
        (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
        FStar_Syntax_Syntax.syntax)
  =
  fun env  ->
    fun t0  ->
      let t =
        FStar_TypeChecker_Normalize.normalize
          [FStar_TypeChecker_Normalize.NoFullNorm;
          FStar_TypeChecker_Normalize.Beta] env t0
         in
      let univnames = gather_free_univnames env t  in
      let univs = FStar_Syntax_Free.univs t  in
      (let uu____5350 =
         FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
           (FStar_Options.Other "Gen")
          in
       match uu____5350 with
       | true  ->
           let uu____5351 = string_of_univs univs  in
           FStar_Util.print1 "univs to gen : %s\n" uu____5351
       | uu____5353 -> ());
      (let gen = gen_univs env univs  in
       (let uu____5357 =
          FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
            (FStar_Options.Other "Gen")
           in
        match uu____5357 with
        | true  ->
            let uu____5358 = FStar_Syntax_Print.term_to_string t  in
            FStar_Util.print1 "After generalization: %s\n" uu____5358
        | uu____5359 -> ());
       (let univs = check_universe_generalization univnames gen t0  in
        let ts = FStar_Syntax_Subst.close_univ_vars univs t  in
        let uu____5363 = FStar_ST.read t0.FStar_Syntax_Syntax.tk  in
        maybe_set_tk (univs, ts) uu____5363))
  
let gen :
  FStar_TypeChecker_Env.env ->
    (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.comp) Prims.list ->
      (FStar_Syntax_Syntax.univ_name Prims.list * FStar_Syntax_Syntax.term *
        FStar_Syntax_Syntax.comp) Prims.list Prims.option
  =
  fun env  ->
    fun ecs  ->
      let uu____5393 =
        let uu____5394 =
          FStar_Util.for_all
            (fun uu____5399  ->
               match uu____5399 with
               | (uu____5404,c) -> FStar_Syntax_Util.is_pure_or_ghost_comp c)
            ecs
           in
        FStar_All.pipe_left Prims.op_Negation uu____5394  in
      match uu____5393 with
      | true  -> None
      | uu____5421 ->
          let norm c =
            (let uu____5427 =
               FStar_TypeChecker_Env.debug env FStar_Options.Medium  in
             match uu____5427 with
             | true  ->
                 let uu____5428 = FStar_Syntax_Print.comp_to_string c  in
                 FStar_Util.print1
                   "Normalizing before generalizing:\n\t %s\n" uu____5428
             | uu____5429 -> ());
            (let c =
               let uu____5431 = FStar_TypeChecker_Env.should_verify env  in
               match uu____5431 with
               | true  ->
                   FStar_TypeChecker_Normalize.normalize_comp
                     [FStar_TypeChecker_Normalize.Beta;
                     FStar_TypeChecker_Normalize.Eager_unfolding;
                     FStar_TypeChecker_Normalize.NoFullNorm] env c
               | uu____5432 ->
                   FStar_TypeChecker_Normalize.normalize_comp
                     [FStar_TypeChecker_Normalize.Beta;
                     FStar_TypeChecker_Normalize.NoFullNorm] env c
                in
             (let uu____5434 =
                FStar_TypeChecker_Env.debug env FStar_Options.Medium  in
              match uu____5434 with
              | true  ->
                  let uu____5435 = FStar_Syntax_Print.comp_to_string c  in
                  FStar_Util.print1 "Normalized to:\n\t %s\n" uu____5435
              | uu____5436 -> ());
             c)
             in
          let env_uvars = FStar_TypeChecker_Env.uvars_in_env env  in
          let gen_uvars uvs =
            let uu____5469 = FStar_Util.set_difference uvs env_uvars  in
            FStar_All.pipe_right uu____5469 FStar_Util.set_elements  in
          let uu____5513 =
            let uu____5531 =
              FStar_All.pipe_right ecs
                (FStar_List.map
                   (fun uu____5586  ->
                      match uu____5586 with
                      | (e,c) ->
                          let t =
                            FStar_All.pipe_right
                              (FStar_Syntax_Util.comp_result c)
                              FStar_Syntax_Subst.compress
                             in
                          let c = norm c  in
                          let t = FStar_Syntax_Util.comp_result c  in
                          let univs = FStar_Syntax_Free.univs t  in
                          let uvt = FStar_Syntax_Free.uvars t  in
                          let uvs = gen_uvars uvt  in (univs, (uvs, e, c))))
               in
            FStar_All.pipe_right uu____5531 FStar_List.unzip  in
          (match uu____5513 with
           | (univs,uvars) ->
               let univs =
                 FStar_List.fold_left FStar_Util.set_union
                   FStar_Syntax_Syntax.no_universe_uvars univs
                  in
               let gen_univs = gen_univs env univs  in
               ((let uu____5748 =
                   FStar_TypeChecker_Env.debug env FStar_Options.Medium  in
                 match uu____5748 with
                 | true  ->
                     FStar_All.pipe_right gen_univs
                       (FStar_List.iter
                          (fun x  ->
                             FStar_Util.print1 "Generalizing uvar %s\n"
                               x.FStar_Ident.idText))
                 | uu____5751 -> ());
                (let ecs =
                   FStar_All.pipe_right uvars
                     (FStar_List.map
                        (fun uu____5790  ->
                           match uu____5790 with
                           | (uvs,e,c) ->
                               let tvars =
                                 FStar_All.pipe_right uvs
                                   (FStar_List.map
                                      (fun uu____5847  ->
                                         match uu____5847 with
                                         | (u,k) ->
                                             let uu____5867 =
                                               FStar_Unionfind.find u  in
                                             (match uu____5867 with
                                              | FStar_Syntax_Syntax.Fixed
                                                {
                                                  FStar_Syntax_Syntax.n =
                                                    FStar_Syntax_Syntax.Tm_name
                                                    a;
                                                  FStar_Syntax_Syntax.tk = _;
                                                  FStar_Syntax_Syntax.pos = _;
                                                  FStar_Syntax_Syntax.vars =
                                                    _;_}
                                                |FStar_Syntax_Syntax.Fixed
                                                {
                                                  FStar_Syntax_Syntax.n =
                                                    FStar_Syntax_Syntax.Tm_abs
                                                    (_,{
                                                         FStar_Syntax_Syntax.n
                                                           =
                                                           FStar_Syntax_Syntax.Tm_name
                                                           a;
                                                         FStar_Syntax_Syntax.tk
                                                           = _;
                                                         FStar_Syntax_Syntax.pos
                                                           = _;
                                                         FStar_Syntax_Syntax.vars
                                                           = _;_},_);
                                                  FStar_Syntax_Syntax.tk = _;
                                                  FStar_Syntax_Syntax.pos = _;
                                                  FStar_Syntax_Syntax.vars =
                                                    _;_}
                                                  ->
                                                  (a,
                                                    (Some
                                                       FStar_Syntax_Syntax.imp_tag))
                                              | FStar_Syntax_Syntax.Fixed
                                                  uu____5905 ->
                                                  failwith
                                                    "Unexpected instantiation of mutually recursive uvar"
                                              | uu____5913 ->
                                                  let k =
                                                    FStar_TypeChecker_Normalize.normalize
                                                      [FStar_TypeChecker_Normalize.Beta]
                                                      env k
                                                     in
                                                  let uu____5918 =
                                                    FStar_Syntax_Util.arrow_formals
                                                      k
                                                     in
                                                  (match uu____5918 with
                                                   | (bs,kres) ->
                                                       let a =
                                                         let uu____5942 =
                                                           let uu____5944 =
                                                             FStar_TypeChecker_Env.get_range
                                                               env
                                                              in
                                                           FStar_All.pipe_left
                                                             (fun _0_30  ->
                                                                Some _0_30)
                                                             uu____5944
                                                            in
                                                         FStar_Syntax_Syntax.new_bv
                                                           uu____5942 kres
                                                          in
                                                       let t =
                                                         let uu____5947 =
                                                           FStar_Syntax_Syntax.bv_to_name
                                                             a
                                                            in
                                                         let uu____5948 =
                                                           let uu____5955 =
                                                             let uu____5961 =
                                                               let uu____5962
                                                                 =
                                                                 FStar_Syntax_Syntax.mk_Total
                                                                   kres
                                                                  in
                                                               FStar_Syntax_Util.lcomp_of_comp
                                                                 uu____5962
                                                                in
                                                             FStar_Util.Inl
                                                               uu____5961
                                                              in
                                                           Some uu____5955
                                                            in
                                                         FStar_Syntax_Util.abs
                                                           bs uu____5947
                                                           uu____5948
                                                          in
                                                       (FStar_Syntax_Util.set_uvar
                                                          u t;
                                                        (a,
                                                          (Some
                                                             FStar_Syntax_Syntax.imp_tag)))))))
                                  in
                               let uu____5977 =
                                 match (tvars, gen_univs) with
                                 | ([],[]) -> (e, c)
                                 | ([],uu____5995) ->
                                     let c =
                                       FStar_TypeChecker_Normalize.normalize_comp
                                         [FStar_TypeChecker_Normalize.Beta;
                                         FStar_TypeChecker_Normalize.NoDeltaSteps;
                                         FStar_TypeChecker_Normalize.NoFullNorm]
                                         env c
                                        in
                                     let e =
                                       FStar_TypeChecker_Normalize.normalize
                                         [FStar_TypeChecker_Normalize.Beta;
                                         FStar_TypeChecker_Normalize.NoDeltaSteps;
                                         FStar_TypeChecker_Normalize.NoFullNorm]
                                         env e
                                        in
                                     (e, c)
                                 | uu____6007 ->
                                     let uu____6015 = (e, c)  in
                                     (match uu____6015 with
                                      | (e0,c0) ->
                                          let c =
                                            FStar_TypeChecker_Normalize.normalize_comp
                                              [FStar_TypeChecker_Normalize.Beta;
                                              FStar_TypeChecker_Normalize.NoDeltaSteps;
                                              FStar_TypeChecker_Normalize.CompressUvars;
                                              FStar_TypeChecker_Normalize.NoFullNorm]
                                              env c
                                             in
                                          let e =
                                            FStar_TypeChecker_Normalize.normalize
                                              [FStar_TypeChecker_Normalize.Beta;
                                              FStar_TypeChecker_Normalize.NoDeltaSteps;
                                              FStar_TypeChecker_Normalize.CompressUvars;
                                              FStar_TypeChecker_Normalize.Exclude
                                                FStar_TypeChecker_Normalize.Zeta;
                                              FStar_TypeChecker_Normalize.Exclude
                                                FStar_TypeChecker_Normalize.Iota;
                                              FStar_TypeChecker_Normalize.NoFullNorm]
                                              env e
                                             in
                                          let t =
                                            let uu____6027 =
                                              let uu____6028 =
                                                FStar_Syntax_Subst.compress
                                                  (FStar_Syntax_Util.comp_result
                                                     c)
                                                 in
                                              uu____6028.FStar_Syntax_Syntax.n
                                               in
                                            match uu____6027 with
                                            | FStar_Syntax_Syntax.Tm_arrow
                                                (bs,cod) ->
                                                let uu____6045 =
                                                  FStar_Syntax_Subst.open_comp
                                                    bs cod
                                                   in
                                                (match uu____6045 with
                                                 | (bs,cod) ->
                                                     FStar_Syntax_Util.arrow
                                                       (FStar_List.append
                                                          tvars bs) cod)
                                            | uu____6055 ->
                                                FStar_Syntax_Util.arrow tvars
                                                  c
                                             in
                                          let e' =
                                            FStar_Syntax_Util.abs tvars e
                                              (Some
                                                 (FStar_Util.Inl
                                                    (FStar_Syntax_Util.lcomp_of_comp
                                                       c)))
                                             in
                                          let uu____6065 =
                                            FStar_Syntax_Syntax.mk_Total t
                                             in
                                          (e', uu____6065))
                                  in
                               (match uu____5977 with
                                | (e,c) -> (gen_univs, e, c))))
                    in
                 Some ecs)))
  
let generalize :
  FStar_TypeChecker_Env.env ->
    (FStar_Syntax_Syntax.lbname * FStar_Syntax_Syntax.term *
      FStar_Syntax_Syntax.comp) Prims.list ->
      (FStar_Syntax_Syntax.lbname * FStar_Syntax_Syntax.univ_name Prims.list
        * FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.comp) Prims.list
  =
  fun env  ->
    fun lecs  ->
      (let uu____6103 = FStar_TypeChecker_Env.debug env FStar_Options.Low  in
       match uu____6103 with
       | true  ->
           let uu____6104 =
             let uu____6105 =
               FStar_List.map
                 (fun uu____6110  ->
                    match uu____6110 with
                    | (lb,uu____6115,uu____6116) ->
                        FStar_Syntax_Print.lbname_to_string lb) lecs
                in
             FStar_All.pipe_right uu____6105 (FStar_String.concat ", ")  in
           FStar_Util.print1 "Generalizing: %s\n" uu____6104
       | uu____6118 -> ());
      (let univnames_lecs =
         FStar_List.map
           (fun uu____6126  ->
              match uu____6126 with | (l,t,c) -> gather_free_univnames env t)
           lecs
          in
       let generalized_lecs =
         let uu____6141 =
           let uu____6148 =
             FStar_All.pipe_right lecs
               (FStar_List.map
                  (fun uu____6164  ->
                     match uu____6164 with | (uu____6170,e,c) -> (e, c)))
              in
           gen env uu____6148  in
         match uu____6141 with
         | None  ->
             FStar_All.pipe_right lecs
               (FStar_List.map
                  (fun uu____6202  ->
                     match uu____6202 with | (l,t,c) -> (l, [], t, c)))
         | Some ecs ->
             FStar_List.map2
               (fun uu____6246  ->
                  fun uu____6247  ->
                    match (uu____6246, uu____6247) with
                    | ((l,uu____6280,uu____6281),(us,e,c)) ->
                        ((let uu____6307 =
                            FStar_TypeChecker_Env.debug env
                              FStar_Options.Medium
                             in
                          match uu____6307 with
                          | true  ->
                              let uu____6308 =
                                FStar_Range.string_of_range
                                  e.FStar_Syntax_Syntax.pos
                                 in
                              let uu____6309 =
                                FStar_Syntax_Print.lbname_to_string l  in
                              let uu____6310 =
                                FStar_Syntax_Print.term_to_string
                                  (FStar_Syntax_Util.comp_result c)
                                 in
                              let uu____6311 =
                                FStar_Syntax_Print.term_to_string e  in
                              FStar_Util.print4
                                "(%s) Generalized %s at type %s\n%s\n"
                                uu____6308 uu____6309 uu____6310 uu____6311
                          | uu____6312 -> ());
                         (l, us, e, c))) lecs ecs
          in
       FStar_List.map2
         (fun univnames  ->
            fun uu____6330  ->
              match uu____6330 with
              | (l,generalized_univs,t,c) ->
                  let uu____6348 =
                    check_universe_generalization univnames generalized_univs
                      t
                     in
                  (l, uu____6348, t, c)) univnames_lecs generalized_lecs)
  
let check_and_ascribe :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Syntax_Syntax.typ ->
        FStar_Syntax_Syntax.typ ->
          (FStar_Syntax_Syntax.term * FStar_TypeChecker_Env.guard_t)
  =
  fun env  ->
    fun e  ->
      fun t1  ->
        fun t2  ->
          let env =
            FStar_TypeChecker_Env.set_range env e.FStar_Syntax_Syntax.pos  in
          let check env t1 t2 =
            match env.FStar_TypeChecker_Env.use_eq with
            | true  -> FStar_TypeChecker_Rel.try_teq env t1 t2
            | uu____6380 ->
                let uu____6381 = FStar_TypeChecker_Rel.try_subtype env t1 t2
                   in
                (match uu____6381 with
                 | None  -> None
                 | Some f ->
                     let uu____6385 = FStar_TypeChecker_Rel.apply_guard f e
                        in
                     FStar_All.pipe_left (fun _0_31  -> Some _0_31)
                       uu____6385)
             in
          let is_var e =
            let uu____6391 =
              let uu____6392 = FStar_Syntax_Subst.compress e  in
              uu____6392.FStar_Syntax_Syntax.n  in
            match uu____6391 with
            | FStar_Syntax_Syntax.Tm_name uu____6395 -> true
            | uu____6396 -> false  in
          let decorate e t =
            let e = FStar_Syntax_Subst.compress e  in
            match e.FStar_Syntax_Syntax.n with
            | FStar_Syntax_Syntax.Tm_name x ->
                (FStar_Syntax_Syntax.mk
                   (FStar_Syntax_Syntax.Tm_name
                      (let uu___137_6418 = x  in
                       {
                         FStar_Syntax_Syntax.ppname =
                           (uu___137_6418.FStar_Syntax_Syntax.ppname);
                         FStar_Syntax_Syntax.index =
                           (uu___137_6418.FStar_Syntax_Syntax.index);
                         FStar_Syntax_Syntax.sort = t2
                       }))) (Some (t2.FStar_Syntax_Syntax.n))
                  e.FStar_Syntax_Syntax.pos
            | uu____6419 ->
                let uu___138_6420 = e  in
                let uu____6421 =
                  FStar_Util.mk_ref (Some (t2.FStar_Syntax_Syntax.n))  in
                {
                  FStar_Syntax_Syntax.n =
                    (uu___138_6420.FStar_Syntax_Syntax.n);
                  FStar_Syntax_Syntax.tk = uu____6421;
                  FStar_Syntax_Syntax.pos =
                    (uu___138_6420.FStar_Syntax_Syntax.pos);
                  FStar_Syntax_Syntax.vars =
                    (uu___138_6420.FStar_Syntax_Syntax.vars)
                }
             in
          let env =
            let uu___139_6430 = env  in
            let uu____6431 =
              env.FStar_TypeChecker_Env.use_eq ||
                (env.FStar_TypeChecker_Env.is_pattern && (is_var e))
               in
            {
              FStar_TypeChecker_Env.solver =
                (uu___139_6430.FStar_TypeChecker_Env.solver);
              FStar_TypeChecker_Env.range =
                (uu___139_6430.FStar_TypeChecker_Env.range);
              FStar_TypeChecker_Env.curmodule =
                (uu___139_6430.FStar_TypeChecker_Env.curmodule);
              FStar_TypeChecker_Env.gamma =
                (uu___139_6430.FStar_TypeChecker_Env.gamma);
              FStar_TypeChecker_Env.gamma_cache =
                (uu___139_6430.FStar_TypeChecker_Env.gamma_cache);
              FStar_TypeChecker_Env.modules =
                (uu___139_6430.FStar_TypeChecker_Env.modules);
              FStar_TypeChecker_Env.expected_typ =
                (uu___139_6430.FStar_TypeChecker_Env.expected_typ);
              FStar_TypeChecker_Env.sigtab =
                (uu___139_6430.FStar_TypeChecker_Env.sigtab);
              FStar_TypeChecker_Env.is_pattern =
                (uu___139_6430.FStar_TypeChecker_Env.is_pattern);
              FStar_TypeChecker_Env.instantiate_imp =
                (uu___139_6430.FStar_TypeChecker_Env.instantiate_imp);
              FStar_TypeChecker_Env.effects =
                (uu___139_6430.FStar_TypeChecker_Env.effects);
              FStar_TypeChecker_Env.generalize =
                (uu___139_6430.FStar_TypeChecker_Env.generalize);
              FStar_TypeChecker_Env.letrecs =
                (uu___139_6430.FStar_TypeChecker_Env.letrecs);
              FStar_TypeChecker_Env.top_level =
                (uu___139_6430.FStar_TypeChecker_Env.top_level);
              FStar_TypeChecker_Env.check_uvars =
                (uu___139_6430.FStar_TypeChecker_Env.check_uvars);
              FStar_TypeChecker_Env.use_eq = uu____6431;
              FStar_TypeChecker_Env.is_iface =
                (uu___139_6430.FStar_TypeChecker_Env.is_iface);
              FStar_TypeChecker_Env.admit =
                (uu___139_6430.FStar_TypeChecker_Env.admit);
              FStar_TypeChecker_Env.lax =
                (uu___139_6430.FStar_TypeChecker_Env.lax);
              FStar_TypeChecker_Env.lax_universes =
                (uu___139_6430.FStar_TypeChecker_Env.lax_universes);
              FStar_TypeChecker_Env.type_of =
                (uu___139_6430.FStar_TypeChecker_Env.type_of);
              FStar_TypeChecker_Env.universe_of =
                (uu___139_6430.FStar_TypeChecker_Env.universe_of);
              FStar_TypeChecker_Env.use_bv_sorts =
                (uu___139_6430.FStar_TypeChecker_Env.use_bv_sorts);
              FStar_TypeChecker_Env.qname_and_index =
                (uu___139_6430.FStar_TypeChecker_Env.qname_and_index)
            }  in
          let uu____6432 = check env t1 t2  in
          match uu____6432 with
          | None  ->
              let uu____6436 =
                let uu____6437 =
                  let uu____6440 =
                    FStar_TypeChecker_Err.expected_expression_of_type env t2
                      e t1
                     in
                  let uu____6441 = FStar_TypeChecker_Env.get_range env  in
                  (uu____6440, uu____6441)  in
                FStar_Errors.Error uu____6437  in
              Prims.raise uu____6436
          | Some g ->
              ((let uu____6446 =
                  FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                    (FStar_Options.Other "Rel")
                   in
                match uu____6446 with
                | true  ->
                    let uu____6447 =
                      FStar_TypeChecker_Rel.guard_to_string env g  in
                    FStar_All.pipe_left
                      (FStar_Util.print1 "Applied guard is %s\n") uu____6447
                | uu____6448 -> ());
               (let uu____6449 = decorate e t2  in (uu____6449, g)))
  
let check_top_level :
  FStar_TypeChecker_Env.env ->
    FStar_TypeChecker_Env.guard_t ->
      FStar_Syntax_Syntax.lcomp -> (Prims.bool * FStar_Syntax_Syntax.comp)
  =
  fun env  ->
    fun g  ->
      fun lc  ->
        let discharge g =
          FStar_TypeChecker_Rel.force_trivial_guard env g;
          FStar_Syntax_Util.is_pure_lcomp lc  in
        let g = FStar_TypeChecker_Rel.solve_deferred_constraints env g  in
        let uu____6473 = FStar_Syntax_Util.is_total_lcomp lc  in
        match uu____6473 with
        | true  ->
            let uu____6476 = discharge g  in
            let uu____6477 = lc.FStar_Syntax_Syntax.comp ()  in
            (uu____6476, uu____6477)
        | uu____6482 ->
            let c = lc.FStar_Syntax_Syntax.comp ()  in
            let steps = [FStar_TypeChecker_Normalize.Beta]  in
            let c =
              let uu____6489 =
                let uu____6490 =
                  let uu____6491 =
                    FStar_TypeChecker_Normalize.unfold_effect_abbrev env c
                     in
                  FStar_All.pipe_right uu____6491 FStar_Syntax_Syntax.mk_Comp
                   in
                FStar_All.pipe_right uu____6490
                  (FStar_TypeChecker_Normalize.normalize_comp steps env)
                 in
              FStar_All.pipe_right uu____6489
                (FStar_TypeChecker_Normalize.comp_to_comp_typ env)
               in
            let md =
              FStar_TypeChecker_Env.get_effect_decl env
                c.FStar_Syntax_Syntax.effect_name
               in
            let uu____6493 = destruct_comp c  in
            (match uu____6493 with
             | (u_t,t,wp) ->
                 let vc =
                   let uu____6505 = FStar_TypeChecker_Env.get_range env  in
                   let uu____6506 =
                     let uu____6507 =
                       FStar_TypeChecker_Env.inst_effect_fun_with [u_t] env
                         md md.FStar_Syntax_Syntax.trivial
                        in
                     let uu____6508 =
                       let uu____6509 = FStar_Syntax_Syntax.as_arg t  in
                       let uu____6510 =
                         let uu____6512 = FStar_Syntax_Syntax.as_arg wp  in
                         [uu____6512]  in
                       uu____6509 :: uu____6510  in
                     FStar_Syntax_Syntax.mk_Tm_app uu____6507 uu____6508  in
                   uu____6506
                     (Some (FStar_Syntax_Util.ktype0.FStar_Syntax_Syntax.n))
                     uu____6505
                    in
                 ((let uu____6518 =
                     FStar_All.pipe_left (FStar_TypeChecker_Env.debug env)
                       (FStar_Options.Other "Simplification")
                      in
                   match uu____6518 with
                   | true  ->
                       let uu____6519 = FStar_Syntax_Print.term_to_string vc
                          in
                       FStar_Util.print1 "top-level VC: %s\n" uu____6519
                   | uu____6520 -> ());
                  (let g =
                     let uu____6522 =
                       FStar_All.pipe_left
                         FStar_TypeChecker_Rel.guard_of_guard_formula
                         (FStar_TypeChecker_Common.NonTrivial vc)
                        in
                     FStar_TypeChecker_Rel.conj_guard g uu____6522  in
                   let uu____6523 = discharge g  in
                   let uu____6524 = FStar_Syntax_Syntax.mk_Comp c  in
                   (uu____6523, uu____6524))))
  
let short_circuit :
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.args -> FStar_TypeChecker_Common.guard_formula
  =
  fun head  ->
    fun seen_args  ->
      let short_bin_op f uu___96_6548 =
        match uu___96_6548 with
        | [] -> FStar_TypeChecker_Common.Trivial
        | (fst,uu____6554)::[] -> f fst
        | uu____6567 -> failwith "Unexpexted args to binary operator"  in
      let op_and_e e =
        let uu____6572 = FStar_Syntax_Util.b2t e  in
        FStar_All.pipe_right uu____6572
          (fun _0_32  -> FStar_TypeChecker_Common.NonTrivial _0_32)
         in
      let op_or_e e =
        let uu____6581 =
          let uu____6584 = FStar_Syntax_Util.b2t e  in
          FStar_Syntax_Util.mk_neg uu____6584  in
        FStar_All.pipe_right uu____6581
          (fun _0_33  -> FStar_TypeChecker_Common.NonTrivial _0_33)
         in
      let op_and_t t =
        FStar_All.pipe_right t
          (fun _0_34  -> FStar_TypeChecker_Common.NonTrivial _0_34)
         in
      let op_or_t t =
        let uu____6595 = FStar_All.pipe_right t FStar_Syntax_Util.mk_neg  in
        FStar_All.pipe_right uu____6595
          (fun _0_35  -> FStar_TypeChecker_Common.NonTrivial _0_35)
         in
      let op_imp_t t =
        FStar_All.pipe_right t
          (fun _0_36  -> FStar_TypeChecker_Common.NonTrivial _0_36)
         in
      let short_op_ite uu___97_6609 =
        match uu___97_6609 with
        | [] -> FStar_TypeChecker_Common.Trivial
        | (guard,uu____6615)::[] -> FStar_TypeChecker_Common.NonTrivial guard
        | _then::(guard,uu____6630)::[] ->
            let uu____6651 = FStar_Syntax_Util.mk_neg guard  in
            FStar_All.pipe_right uu____6651
              (fun _0_37  -> FStar_TypeChecker_Common.NonTrivial _0_37)
        | uu____6656 -> failwith "Unexpected args to ITE"  in
      let table =
        let uu____6663 =
          let uu____6668 = short_bin_op op_and_e  in
          (FStar_Syntax_Const.op_And, uu____6668)  in
        let uu____6673 =
          let uu____6679 =
            let uu____6684 = short_bin_op op_or_e  in
            (FStar_Syntax_Const.op_Or, uu____6684)  in
          let uu____6689 =
            let uu____6695 =
              let uu____6700 = short_bin_op op_and_t  in
              (FStar_Syntax_Const.and_lid, uu____6700)  in
            let uu____6705 =
              let uu____6711 =
                let uu____6716 = short_bin_op op_or_t  in
                (FStar_Syntax_Const.or_lid, uu____6716)  in
              let uu____6721 =
                let uu____6727 =
                  let uu____6732 = short_bin_op op_imp_t  in
                  (FStar_Syntax_Const.imp_lid, uu____6732)  in
                [uu____6727; (FStar_Syntax_Const.ite_lid, short_op_ite)]  in
              uu____6711 :: uu____6721  in
            uu____6695 :: uu____6705  in
          uu____6679 :: uu____6689  in
        uu____6663 :: uu____6673  in
      match head.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_fvar fv ->
          let lid = (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
             in
          let uu____6773 =
            FStar_Util.find_map table
              (fun uu____6779  ->
                 match uu____6779 with
                 | (x,mk) ->
                     (match FStar_Ident.lid_equals x lid with
                      | true  ->
                          let uu____6792 = mk seen_args  in Some uu____6792
                      | uu____6793 -> None))
             in
          (match uu____6773 with
           | None  -> FStar_TypeChecker_Common.Trivial
           | Some g -> g)
      | uu____6795 -> FStar_TypeChecker_Common.Trivial
  
let short_circuit_head : FStar_Syntax_Syntax.term -> Prims.bool =
  fun l  ->
    let uu____6799 =
      let uu____6800 = FStar_Syntax_Util.un_uinst l  in
      uu____6800.FStar_Syntax_Syntax.n  in
    match uu____6799 with
    | FStar_Syntax_Syntax.Tm_fvar fv ->
        FStar_Util.for_some (FStar_Syntax_Syntax.fv_eq_lid fv)
          [FStar_Syntax_Const.op_And;
          FStar_Syntax_Const.op_Or;
          FStar_Syntax_Const.and_lid;
          FStar_Syntax_Const.or_lid;
          FStar_Syntax_Const.imp_lid;
          FStar_Syntax_Const.ite_lid]
    | uu____6804 -> false
  
let maybe_add_implicit_binders :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.binders -> FStar_Syntax_Syntax.binders
  =
  fun env  ->
    fun bs  ->
      let pos bs =
        match bs with
        | (hd,uu____6822)::uu____6823 -> FStar_Syntax_Syntax.range_of_bv hd
        | uu____6829 -> FStar_TypeChecker_Env.get_range env  in
      match bs with
      | (uu____6833,Some (FStar_Syntax_Syntax.Implicit uu____6834))::uu____6835
          -> bs
      | uu____6844 ->
          let uu____6845 = FStar_TypeChecker_Env.expected_typ env  in
          (match uu____6845 with
           | None  -> bs
           | Some t ->
               let uu____6848 =
                 let uu____6849 = FStar_Syntax_Subst.compress t  in
                 uu____6849.FStar_Syntax_Syntax.n  in
               (match uu____6848 with
                | FStar_Syntax_Syntax.Tm_arrow (bs',uu____6853) ->
                    let uu____6864 =
                      FStar_Util.prefix_until
                        (fun uu___98_6883  ->
                           match uu___98_6883 with
                           | (uu____6887,Some (FStar_Syntax_Syntax.Implicit
                              uu____6888)) -> false
                           | uu____6890 -> true) bs'
                       in
                    (match uu____6864 with
                     | None  -> bs
                     | Some ([],uu____6908,uu____6909) -> bs
                     | Some (imps,uu____6946,uu____6947) ->
                         let uu____6984 =
                           FStar_All.pipe_right imps
                             (FStar_Util.for_all
                                (fun uu____6992  ->
                                   match uu____6992 with
                                   | (x,uu____6997) ->
                                       FStar_Util.starts_with
                                         (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
                                         "'"))
                            in
                         (match uu____6984 with
                          | true  ->
                              let r = pos bs  in
                              let imps =
                                FStar_All.pipe_right imps
                                  (FStar_List.map
                                     (fun uu____7020  ->
                                        match uu____7020 with
                                        | (x,i) ->
                                            let uu____7031 =
                                              FStar_Syntax_Syntax.set_range_of_bv
                                                x r
                                               in
                                            (uu____7031, i)))
                                 in
                              FStar_List.append imps bs
                          | uu____7036 -> bs))
                | uu____7037 -> bs))
  
let maybe_lift :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Ident.lident ->
        FStar_Ident.lident ->
          FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.term
  =
  fun env  ->
    fun e  ->
      fun c1  ->
        fun c2  ->
          fun t  ->
            let m1 = FStar_TypeChecker_Env.norm_eff_name env c1  in
            let m2 = FStar_TypeChecker_Env.norm_eff_name env c2  in
            match ((FStar_Ident.lid_equals m1 m2) ||
                     ((FStar_Syntax_Util.is_pure_effect c1) &&
                        (FStar_Syntax_Util.is_ghost_effect c2)))
                    ||
                    ((FStar_Syntax_Util.is_pure_effect c2) &&
                       (FStar_Syntax_Util.is_ghost_effect c1))
            with
            | true  -> e
            | uu____7055 ->
                let uu____7056 = FStar_ST.read e.FStar_Syntax_Syntax.tk  in
                (FStar_Syntax_Syntax.mk
                   (FStar_Syntax_Syntax.Tm_meta
                      (e,
                        (FStar_Syntax_Syntax.Meta_monadic_lift (m1, m2, t)))))
                  uu____7056 e.FStar_Syntax_Syntax.pos
  
let maybe_monadic :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term ->
      FStar_Ident.lident ->
        FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.term
  =
  fun env  ->
    fun e  ->
      fun c  ->
        fun t  ->
          let m = FStar_TypeChecker_Env.norm_eff_name env c  in
          let uu____7082 =
            ((is_pure_or_ghost_effect env m) ||
               (FStar_Ident.lid_equals m FStar_Syntax_Const.effect_Tot_lid))
              ||
              (FStar_Ident.lid_equals m FStar_Syntax_Const.effect_GTot_lid)
             in
          match uu____7082 with
          | true  -> e
          | uu____7083 ->
              let uu____7084 = FStar_ST.read e.FStar_Syntax_Syntax.tk  in
              (FStar_Syntax_Syntax.mk
                 (FStar_Syntax_Syntax.Tm_meta
                    (e, (FStar_Syntax_Syntax.Meta_monadic (m, t)))))
                uu____7084 e.FStar_Syntax_Syntax.pos
  
let effect_repr_aux only_reifiable env c u_c =
  let uu____7126 =
    let uu____7128 =
      FStar_TypeChecker_Env.norm_eff_name env
        (FStar_Syntax_Util.comp_effect_name c)
       in
    FStar_TypeChecker_Env.effect_decl_opt env uu____7128  in
  match uu____7126 with
  | None  -> None
  | Some ed ->
      let uu____7135 =
        only_reifiable &&
          (let uu____7136 =
             FStar_All.pipe_right ed.FStar_Syntax_Syntax.qualifiers
               (FStar_List.contains FStar_Syntax_Syntax.Reifiable)
              in
           Prims.op_Negation uu____7136)
         in
      (match uu____7135 with
       | true  -> None
       | uu____7143 ->
           (match (ed.FStar_Syntax_Syntax.repr).FStar_Syntax_Syntax.n with
            | FStar_Syntax_Syntax.Tm_unknown  -> None
            | uu____7149 ->
                let c =
                  FStar_TypeChecker_Normalize.unfold_effect_abbrev env c  in
                let uu____7151 =
                  let uu____7160 =
                    FStar_List.hd c.FStar_Syntax_Syntax.effect_args  in
                  ((c.FStar_Syntax_Syntax.result_typ), uu____7160)  in
                (match uu____7151 with
                 | (res_typ,wp) ->
                     let repr =
                       FStar_TypeChecker_Env.inst_effect_fun_with [u_c] env
                         ed ([], (ed.FStar_Syntax_Syntax.repr))
                        in
                     let uu____7194 =
                       let uu____7197 = FStar_TypeChecker_Env.get_range env
                          in
                       let uu____7198 =
                         let uu____7201 =
                           let uu____7202 =
                             let uu____7212 =
                               let uu____7214 =
                                 FStar_Syntax_Syntax.as_arg res_typ  in
                               [uu____7214; wp]  in
                             (repr, uu____7212)  in
                           FStar_Syntax_Syntax.Tm_app uu____7202  in
                         FStar_Syntax_Syntax.mk uu____7201  in
                       uu____7198 None uu____7197  in
                     Some uu____7194)))
  
let effect_repr :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.comp ->
      FStar_Syntax_Syntax.universe ->
        (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
          FStar_Syntax_Syntax.syntax Prims.option
  = fun env  -> fun c  -> fun u_c  -> effect_repr_aux false env c u_c 
let reify_comp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.lcomp ->
      FStar_Syntax_Syntax.universe -> FStar_Syntax_Syntax.term
  =
  fun env  ->
    fun c  ->
      fun u_c  ->
        let no_reify l =
          let uu____7258 =
            let uu____7259 =
              let uu____7262 =
                FStar_Util.format1 "Effect %s cannot be reified"
                  l.FStar_Ident.str
                 in
              let uu____7263 = FStar_TypeChecker_Env.get_range env  in
              (uu____7262, uu____7263)  in
            FStar_Errors.Error uu____7259  in
          Prims.raise uu____7258  in
        let uu____7264 =
          let uu____7268 = c.FStar_Syntax_Syntax.comp ()  in
          effect_repr_aux true env uu____7268 u_c  in
        match uu____7264 with
        | None  -> no_reify c.FStar_Syntax_Syntax.eff_name
        | Some tm -> tm
  
let d : Prims.string -> Prims.unit =
  fun s  -> FStar_Util.print1 "\\x1b[01;36m%s\\x1b[00m\n" s 
let mk_toplevel_definition :
  FStar_TypeChecker_Env.env_t ->
    FStar_Ident.lident ->
      FStar_Syntax_Syntax.term ->
        (FStar_Syntax_Syntax.sigelt *
          (FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
          FStar_Syntax_Syntax.syntax)
  =
  fun env  ->
    fun lident  ->
      fun def  ->
        (let uu____7295 =
           FStar_TypeChecker_Env.debug env (FStar_Options.Other "ED")  in
         match uu____7295 with
         | true  ->
             (d (FStar_Ident.text_of_lid lident);
              (let uu____7297 = FStar_Syntax_Print.term_to_string def  in
               FStar_Util.print2 "Registering top-level definition: %s\n%s\n"
                 (FStar_Ident.text_of_lid lident) uu____7297))
         | uu____7298 -> ());
        (let fv =
           let uu____7300 = FStar_Syntax_Util.incr_delta_qualifier def  in
           FStar_Syntax_Syntax.lid_as_fv lident uu____7300 None  in
         let lbname = FStar_Util.Inr fv  in
         let lb =
           (false,
             [{
                FStar_Syntax_Syntax.lbname = lbname;
                FStar_Syntax_Syntax.lbunivs = [];
                FStar_Syntax_Syntax.lbtyp = FStar_Syntax_Syntax.tun;
                FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_Tot_lid;
                FStar_Syntax_Syntax.lbdef = def
              }])
            in
         let sig_ctx =
           FStar_Syntax_Syntax.Sig_let
             (lb, FStar_Range.dummyRange, [lident],
               [FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen], [])
            in
         let uu____7308 =
           (FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_fvar fv)) None
             FStar_Range.dummyRange
            in
         (sig_ctx, uu____7308))
  
let check_sigelt_quals :
  FStar_TypeChecker_Env.env -> FStar_Syntax_Syntax.sigelt -> Prims.unit =
  fun env  ->
    fun se  ->
      let visibility uu___99_7330 =
        match uu___99_7330 with
        | FStar_Syntax_Syntax.Private  -> true
        | uu____7331 -> false  in
      let reducibility uu___100_7335 =
        match uu___100_7335 with
        | FStar_Syntax_Syntax.Abstract 
          |FStar_Syntax_Syntax.Irreducible 
           |FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen 
            |FStar_Syntax_Syntax.Visible_default 
             |FStar_Syntax_Syntax.Inline_for_extraction 
            -> true
        | uu____7336 -> false  in
      let assumption uu___101_7340 =
        match uu___101_7340 with
        | FStar_Syntax_Syntax.Assumption |FStar_Syntax_Syntax.New  -> true
        | uu____7341 -> false  in
      let reification uu___102_7345 =
        match uu___102_7345 with
        | FStar_Syntax_Syntax.Reifiable |FStar_Syntax_Syntax.Reflectable _ ->
            true
        | uu____7347 -> false  in
      let inferred uu___103_7351 =
        match uu___103_7351 with
        | FStar_Syntax_Syntax.Discriminator _
          |FStar_Syntax_Syntax.Projector _
           |FStar_Syntax_Syntax.RecordType _
            |FStar_Syntax_Syntax.RecordConstructor _
             |FStar_Syntax_Syntax.ExceptionConstructor 
              |FStar_Syntax_Syntax.HasMaskedEffect 
               |FStar_Syntax_Syntax.Effect 
            -> true
        | uu____7356 -> false  in
      let has_eq uu___104_7360 =
        match uu___104_7360 with
        | FStar_Syntax_Syntax.Noeq |FStar_Syntax_Syntax.Unopteq  -> true
        | uu____7361 -> false  in
      let quals_combo_ok quals q =
        match q with
        | FStar_Syntax_Syntax.Assumption  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    (((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                         (inferred x))
                        || (visibility x))
                       || (assumption x))
                      ||
                      (env.FStar_TypeChecker_Env.is_iface &&
                         (x = FStar_Syntax_Syntax.Inline_for_extraction))))
        | FStar_Syntax_Syntax.New  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    (((x = q) || (inferred x)) || (visibility x)) ||
                      (assumption x)))
        | FStar_Syntax_Syntax.Inline_for_extraction  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                          (visibility x))
                         || (reducibility x))
                        || (reification x))
                       || (inferred x))
                      ||
                      (env.FStar_TypeChecker_Env.is_iface &&
                         (x = FStar_Syntax_Syntax.Assumption))))
        | FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen 
          |FStar_Syntax_Syntax.Visible_default 
           |FStar_Syntax_Syntax.Irreducible 
            |FStar_Syntax_Syntax.Abstract 
             |FStar_Syntax_Syntax.Noeq |FStar_Syntax_Syntax.Unopteq 
            ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((((x = q) || (x = FStar_Syntax_Syntax.Logic)) ||
                          (x = FStar_Syntax_Syntax.Abstract))
                         || (x = FStar_Syntax_Syntax.Inline_for_extraction))
                        || (has_eq x))
                       || (inferred x))
                      || (visibility x)))
        | FStar_Syntax_Syntax.TotalEffect  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    (((x = q) || (inferred x)) || (visibility x)) ||
                      (reification x)))
        | FStar_Syntax_Syntax.Logic  ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    ((((x = q) || (x = FStar_Syntax_Syntax.Assumption)) ||
                        (inferred x))
                       || (visibility x))
                      || (reducibility x)))
        | FStar_Syntax_Syntax.Reifiable |FStar_Syntax_Syntax.Reflectable _ ->
            FStar_All.pipe_right quals
              (FStar_List.for_all
                 (fun x  ->
                    (((reification x) || (inferred x)) || (visibility x)) ||
                      (x = FStar_Syntax_Syntax.TotalEffect)))
        | FStar_Syntax_Syntax.Private  -> true
        | uu____7386 -> true  in
      let quals = FStar_Syntax_Util.quals_of_sigelt se  in
      let uu____7389 =
        let uu____7390 =
          FStar_All.pipe_right quals
            (FStar_Util.for_some
               (fun uu___105_7392  ->
                  match uu___105_7392 with
                  | FStar_Syntax_Syntax.OnlyName  -> true
                  | uu____7393 -> false))
           in
        FStar_All.pipe_right uu____7390 Prims.op_Negation  in
      match uu____7389 with
      | true  ->
          let r = FStar_Syntax_Util.range_of_sigelt se  in
          let no_dup_quals =
            FStar_Util.remove_dups (fun x  -> fun y  -> x = y) quals  in
          let err' msg =
            let uu____7403 =
              let uu____7404 =
                let uu____7407 =
                  let uu____7408 = FStar_Syntax_Print.quals_to_string quals
                     in
                  FStar_Util.format2
                    "The qualifier list \"[%s]\" is not permissible for this element%s"
                    uu____7408 msg
                   in
                (uu____7407, r)  in
              FStar_Errors.Error uu____7404  in
            Prims.raise uu____7403  in
          let err msg = err' (Prims.strcat ": " msg)  in
          let err' uu____7416 = err' ""  in
          ((match (FStar_List.length quals) <>
                    (FStar_List.length no_dup_quals)
            with
            | true  -> err "duplicate qualifiers"
            | uu____7422 -> ());
           (let uu____7424 =
              let uu____7425 =
                FStar_All.pipe_right quals
                  (FStar_List.for_all (quals_combo_ok quals))
                 in
              Prims.op_Negation uu____7425  in
            match uu____7424 with
            | true  -> err "ill-formed combination"
            | uu____7427 -> ());
           (match se with
            | FStar_Syntax_Syntax.Sig_let
                ((is_rec,uu____7429),uu____7430,uu____7431,uu____7432,uu____7433)
                ->
                ((let uu____7446 =
                    is_rec &&
                      (FStar_All.pipe_right quals
                         (FStar_List.contains
                            FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen))
                     in
                  match uu____7446 with
                  | true  ->
                      err "recursive definitions cannot be marked inline"
                  | uu____7448 -> ());
                 (let uu____7449 =
                    FStar_All.pipe_right quals
                      (FStar_Util.for_some
                         (fun x  -> (assumption x) || (has_eq x)))
                     in
                  match uu____7449 with
                  | true  ->
                      err
                        "definitions cannot be assumed or marked with equality qualifiers"
                  | uu____7452 -> ()))
            | FStar_Syntax_Syntax.Sig_bundle uu____7453 ->
                let uu____7461 =
                  let uu____7462 =
                    FStar_All.pipe_right quals
                      (FStar_Util.for_all
                         (fun x  ->
                            (((x = FStar_Syntax_Syntax.Abstract) ||
                                (inferred x))
                               || (visibility x))
                              || (has_eq x)))
                     in
                  Prims.op_Negation uu____7462  in
                (match uu____7461 with | true  -> err' () | uu____7465 -> ())
            | FStar_Syntax_Syntax.Sig_declare_typ uu____7466 ->
                let uu____7473 =
                  FStar_All.pipe_right quals (FStar_Util.for_some has_eq)  in
                (match uu____7473 with | true  -> err' () | uu____7475 -> ())
            | FStar_Syntax_Syntax.Sig_assume uu____7476 ->
                let uu____7482 =
                  let uu____7483 =
                    FStar_All.pipe_right quals
                      (FStar_Util.for_all
                         (fun x  ->
                            (visibility x) ||
                              (x = FStar_Syntax_Syntax.Assumption)))
                     in
                  Prims.op_Negation uu____7483  in
                (match uu____7482 with | true  -> err' () | uu____7486 -> ())
            | FStar_Syntax_Syntax.Sig_new_effect uu____7487 ->
                let uu____7490 =
                  let uu____7491 =
                    FStar_All.pipe_right quals
                      (FStar_Util.for_all
                         (fun x  ->
                            (((x = FStar_Syntax_Syntax.TotalEffect) ||
                                (inferred x))
                               || (visibility x))
                              || (reification x)))
                     in
                  Prims.op_Negation uu____7491  in
                (match uu____7490 with | true  -> err' () | uu____7494 -> ())
            | FStar_Syntax_Syntax.Sig_new_effect_for_free uu____7495 ->
                let uu____7498 =
                  let uu____7499 =
                    FStar_All.pipe_right quals
                      (FStar_Util.for_all
                         (fun x  ->
                            (((x = FStar_Syntax_Syntax.TotalEffect) ||
                                (inferred x))
                               || (visibility x))
                              || (reification x)))
                     in
                  Prims.op_Negation uu____7499  in
                (match uu____7498 with | true  -> err' () | uu____7502 -> ())
            | FStar_Syntax_Syntax.Sig_effect_abbrev uu____7503 ->
                let uu____7513 =
                  let uu____7514 =
                    FStar_All.pipe_right quals
                      (FStar_Util.for_all
                         (fun x  -> (inferred x) || (visibility x)))
                     in
                  Prims.op_Negation uu____7514  in
                (match uu____7513 with | true  -> err' () | uu____7517 -> ())
            | uu____7518 -> ()))
      | uu____7519 -> ()
  
let mk_discriminator_and_indexed_projectors :
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_Syntax_Syntax.fv_qual ->
      Prims.bool ->
        FStar_TypeChecker_Env.env ->
          FStar_Ident.lident ->
            FStar_Ident.lident ->
              FStar_Syntax_Syntax.univ_names ->
                FStar_Syntax_Syntax.binders ->
                  FStar_Syntax_Syntax.binders ->
                    FStar_Syntax_Syntax.binders ->
                      FStar_Syntax_Syntax.sigelt Prims.list
  =
  fun iquals  ->
    fun fvq  ->
      fun refine_domain  ->
        fun env  ->
          fun tc  ->
            fun lid  ->
              fun uvs  ->
                fun inductive_tps  ->
                  fun indices  ->
                    fun fields  ->
                      let p = FStar_Ident.range_of_lid lid  in
                      let pos q =
                        FStar_Syntax_Syntax.withinfo q
                          FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n p
                         in
                      let projectee ptyp =
                        FStar_Syntax_Syntax.gen_bv "projectee" (Some p) ptyp
                         in
                      let inst_univs =
                        FStar_List.map
                          (fun u  -> FStar_Syntax_Syntax.U_name u) uvs
                         in
                      let tps = inductive_tps  in
                      let arg_typ =
                        let inst_tc =
                          let uu____7575 =
                            let uu____7578 =
                              let uu____7579 =
                                let uu____7584 =
                                  let uu____7585 =
                                    FStar_Syntax_Syntax.lid_as_fv tc
                                      FStar_Syntax_Syntax.Delta_constant None
                                     in
                                  FStar_Syntax_Syntax.fv_to_tm uu____7585  in
                                (uu____7584, inst_univs)  in
                              FStar_Syntax_Syntax.Tm_uinst uu____7579  in
                            FStar_Syntax_Syntax.mk uu____7578  in
                          uu____7575 None p  in
                        let args =
                          FStar_All.pipe_right
                            (FStar_List.append tps indices)
                            (FStar_List.map
                               (fun uu____7611  ->
                                  match uu____7611 with
                                  | (x,imp) ->
                                      let uu____7618 =
                                        FStar_Syntax_Syntax.bv_to_name x  in
                                      (uu____7618, imp)))
                           in
                        (FStar_Syntax_Syntax.mk_Tm_app inst_tc args) None p
                         in
                      let unrefined_arg_binder =
                        let uu____7624 = projectee arg_typ  in
                        FStar_Syntax_Syntax.mk_binder uu____7624  in
                      let arg_binder =
                        match Prims.op_Negation refine_domain with
                        | true  -> unrefined_arg_binder
                        | uu____7626 ->
                            let disc_name =
                              FStar_Syntax_Util.mk_discriminator lid  in
                            let x =
                              FStar_Syntax_Syntax.new_bv (Some p) arg_typ  in
                            let sort =
                              let disc_fvar =
                                FStar_Syntax_Syntax.fvar
                                  (FStar_Ident.set_lid_range disc_name p)
                                  FStar_Syntax_Syntax.Delta_equational None
                                 in
                              let uu____7633 =
                                let uu____7634 =
                                  let uu____7635 =
                                    let uu____7636 =
                                      FStar_Syntax_Syntax.mk_Tm_uinst
                                        disc_fvar inst_univs
                                       in
                                    let uu____7637 =
                                      let uu____7638 =
                                        let uu____7639 =
                                          FStar_Syntax_Syntax.bv_to_name x
                                           in
                                        FStar_All.pipe_left
                                          FStar_Syntax_Syntax.as_arg
                                          uu____7639
                                         in
                                      [uu____7638]  in
                                    FStar_Syntax_Syntax.mk_Tm_app uu____7636
                                      uu____7637
                                     in
                                  uu____7635 None p  in
                                FStar_Syntax_Util.b2t uu____7634  in
                              FStar_Syntax_Util.refine x uu____7633  in
                            let uu____7644 =
                              let uu___140_7645 = projectee arg_typ  in
                              {
                                FStar_Syntax_Syntax.ppname =
                                  (uu___140_7645.FStar_Syntax_Syntax.ppname);
                                FStar_Syntax_Syntax.index =
                                  (uu___140_7645.FStar_Syntax_Syntax.index);
                                FStar_Syntax_Syntax.sort = sort
                              }  in
                            FStar_Syntax_Syntax.mk_binder uu____7644
                         in
                      let ntps = FStar_List.length tps  in
                      let all_params =
                        let uu____7655 =
                          FStar_List.map
                            (fun uu____7665  ->
                               match uu____7665 with
                               | (x,uu____7672) ->
                                   (x, (Some FStar_Syntax_Syntax.imp_tag)))
                            tps
                           in
                        FStar_List.append uu____7655 fields  in
                      let imp_binders =
                        FStar_All.pipe_right (FStar_List.append tps indices)
                          (FStar_List.map
                             (fun uu____7696  ->
                                match uu____7696 with
                                | (x,uu____7703) ->
                                    (x, (Some FStar_Syntax_Syntax.imp_tag))))
                         in
                      let discriminator_ses =
                        match fvq <> FStar_Syntax_Syntax.Data_ctor with
                        | true  -> []
                        | uu____7708 ->
                            let discriminator_name =
                              FStar_Syntax_Util.mk_discriminator lid  in
                            let no_decl = false  in
                            let only_decl =
                              (let uu____7712 =
                                 FStar_TypeChecker_Env.current_module env  in
                               FStar_Ident.lid_equals
                                 FStar_Syntax_Const.prims_lid uu____7712)
                                ||
                                (let uu____7713 =
                                   let uu____7714 =
                                     FStar_TypeChecker_Env.current_module env
                                      in
                                   uu____7714.FStar_Ident.str  in
                                 FStar_Options.dont_gen_projectors uu____7713)
                               in
                            let quals =
                              let uu____7717 =
                                let uu____7719 =
                                  let uu____7721 =
                                    only_decl &&
                                      ((FStar_All.pipe_left Prims.op_Negation
                                          env.FStar_TypeChecker_Env.is_iface)
                                         || env.FStar_TypeChecker_Env.admit)
                                     in
                                  match uu____7721 with
                                  | true  -> [FStar_Syntax_Syntax.Assumption]
                                  | uu____7723 -> []  in
                                let uu____7724 =
                                  FStar_List.filter
                                    (fun uu___106_7726  ->
                                       match uu___106_7726 with
                                       | FStar_Syntax_Syntax.Abstract  ->
                                           Prims.op_Negation only_decl
                                       | FStar_Syntax_Syntax.Private  -> true
                                       | uu____7727 -> false) iquals
                                   in
                                FStar_List.append uu____7719 uu____7724  in
                              FStar_List.append
                                ((FStar_Syntax_Syntax.Discriminator lid) ::
                                (match only_decl with
                                 | true  -> [FStar_Syntax_Syntax.Logic]
                                 | uu____7729 -> [])) uu____7717
                               in
                            let binders =
                              FStar_List.append imp_binders
                                [unrefined_arg_binder]
                               in
                            let t =
                              let bool_typ =
                                let uu____7740 =
                                  let uu____7741 =
                                    FStar_Syntax_Syntax.lid_as_fv
                                      FStar_Syntax_Const.bool_lid
                                      FStar_Syntax_Syntax.Delta_constant None
                                     in
                                  FStar_Syntax_Syntax.fv_to_tm uu____7741  in
                                FStar_Syntax_Syntax.mk_Total uu____7740  in
                              let uu____7742 =
                                FStar_Syntax_Util.arrow binders bool_typ  in
                              FStar_All.pipe_left
                                (FStar_Syntax_Subst.close_univ_vars uvs)
                                uu____7742
                               in
                            let decl =
                              FStar_Syntax_Syntax.Sig_declare_typ
                                (discriminator_name, uvs, t, quals,
                                  (FStar_Ident.range_of_lid
                                     discriminator_name))
                               in
                            ((let uu____7746 =
                                FStar_TypeChecker_Env.debug env
                                  (FStar_Options.Other "LogTypes")
                                 in
                              match uu____7746 with
                              | true  ->
                                  let uu____7747 =
                                    FStar_Syntax_Print.sigelt_to_string decl
                                     in
                                  FStar_Util.print1
                                    "Declaration of a discriminator %s\n"
                                    uu____7747
                              | uu____7748 -> ());
                             (match only_decl with
                              | true  -> [decl]
                              | uu____7750 ->
                                  let body =
                                    match Prims.op_Negation refine_domain
                                    with
                                    | true  ->
                                        FStar_Syntax_Const.exp_true_bool
                                    | uu____7752 ->
                                        let arg_pats =
                                          FStar_All.pipe_right all_params
                                            (FStar_List.mapi
                                               (fun j  ->
                                                  fun uu____7775  ->
                                                    match uu____7775 with
                                                    | (x,imp) ->
                                                        let b =
                                                          FStar_Syntax_Syntax.is_implicit
                                                            imp
                                                           in
                                                        (match b &&
                                                                 (j < ntps)
                                                         with
                                                         | true  ->
                                                             let uu____7791 =
                                                               let uu____7794
                                                                 =
                                                                 let uu____7795
                                                                   =
                                                                   let uu____7800
                                                                    =
                                                                    FStar_Syntax_Syntax.gen_bv
                                                                    (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
                                                                    None
                                                                    FStar_Syntax_Syntax.tun
                                                                     in
                                                                   (uu____7800,
                                                                    FStar_Syntax_Syntax.tun)
                                                                    in
                                                                 FStar_Syntax_Syntax.Pat_dot_term
                                                                   uu____7795
                                                                  in
                                                               pos uu____7794
                                                                in
                                                             (uu____7791, b)
                                                         | uu____7803 ->
                                                             let uu____7804 =
                                                               let uu____7807
                                                                 =
                                                                 let uu____7808
                                                                   =
                                                                   FStar_Syntax_Syntax.gen_bv
                                                                    (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
                                                                    None
                                                                    FStar_Syntax_Syntax.tun
                                                                    in
                                                                 FStar_Syntax_Syntax.Pat_wild
                                                                   uu____7808
                                                                  in
                                                               pos uu____7807
                                                                in
                                                             (uu____7804, b))))
                                           in
                                        let pat_true =
                                          let uu____7820 =
                                            let uu____7823 =
                                              let uu____7824 =
                                                let uu____7832 =
                                                  FStar_Syntax_Syntax.lid_as_fv
                                                    lid
                                                    FStar_Syntax_Syntax.Delta_constant
                                                    (Some fvq)
                                                   in
                                                (uu____7832, arg_pats)  in
                                              FStar_Syntax_Syntax.Pat_cons
                                                uu____7824
                                               in
                                            pos uu____7823  in
                                          (uu____7820, None,
                                            FStar_Syntax_Const.exp_true_bool)
                                           in
                                        let pat_false =
                                          let uu____7854 =
                                            let uu____7857 =
                                              let uu____7858 =
                                                FStar_Syntax_Syntax.new_bv
                                                  None
                                                  FStar_Syntax_Syntax.tun
                                                 in
                                              FStar_Syntax_Syntax.Pat_wild
                                                uu____7858
                                               in
                                            pos uu____7857  in
                                          (uu____7854, None,
                                            FStar_Syntax_Const.exp_false_bool)
                                           in
                                        let arg_exp =
                                          FStar_Syntax_Syntax.bv_to_name
                                            (Prims.fst unrefined_arg_binder)
                                           in
                                        let uu____7867 =
                                          let uu____7870 =
                                            let uu____7871 =
                                              let uu____7887 =
                                                let uu____7889 =
                                                  FStar_Syntax_Util.branch
                                                    pat_true
                                                   in
                                                let uu____7890 =
                                                  let uu____7892 =
                                                    FStar_Syntax_Util.branch
                                                      pat_false
                                                     in
                                                  [uu____7892]  in
                                                uu____7889 :: uu____7890  in
                                              (arg_exp, uu____7887)  in
                                            FStar_Syntax_Syntax.Tm_match
                                              uu____7871
                                             in
                                          FStar_Syntax_Syntax.mk uu____7870
                                           in
                                        uu____7867 None p
                                     in
                                  let dd =
                                    let uu____7903 =
                                      FStar_All.pipe_right quals
                                        (FStar_List.contains
                                           FStar_Syntax_Syntax.Abstract)
                                       in
                                    match uu____7903 with
                                    | true  ->
                                        FStar_Syntax_Syntax.Delta_abstract
                                          FStar_Syntax_Syntax.Delta_equational
                                    | uu____7905 ->
                                        FStar_Syntax_Syntax.Delta_equational
                                     in
                                  let imp =
                                    FStar_Syntax_Util.abs binders body None
                                     in
                                  let lbtyp =
                                    match no_decl with
                                    | true  -> t
                                    | uu____7913 -> FStar_Syntax_Syntax.tun
                                     in
                                  let lb =
                                    let uu____7915 =
                                      let uu____7918 =
                                        FStar_Syntax_Syntax.lid_as_fv
                                          discriminator_name dd None
                                         in
                                      FStar_Util.Inr uu____7918  in
                                    let uu____7919 =
                                      FStar_Syntax_Subst.close_univ_vars uvs
                                        imp
                                       in
                                    {
                                      FStar_Syntax_Syntax.lbname = uu____7915;
                                      FStar_Syntax_Syntax.lbunivs = uvs;
                                      FStar_Syntax_Syntax.lbtyp = lbtyp;
                                      FStar_Syntax_Syntax.lbeff =
                                        FStar_Syntax_Const.effect_Tot_lid;
                                      FStar_Syntax_Syntax.lbdef = uu____7919
                                    }  in
                                  let impl =
                                    let uu____7923 =
                                      let uu____7932 =
                                        let uu____7934 =
                                          let uu____7935 =
                                            FStar_All.pipe_right
                                              lb.FStar_Syntax_Syntax.lbname
                                              FStar_Util.right
                                             in
                                          FStar_All.pipe_right uu____7935
                                            (fun fv  ->
                                               (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)
                                           in
                                        [uu____7934]  in
                                      ((false, [lb]), p, uu____7932, quals,
                                        [])
                                       in
                                    FStar_Syntax_Syntax.Sig_let uu____7923
                                     in
                                  ((let uu____7951 =
                                      FStar_TypeChecker_Env.debug env
                                        (FStar_Options.Other "LogTypes")
                                       in
                                    match uu____7951 with
                                    | true  ->
                                        let uu____7952 =
                                          FStar_Syntax_Print.sigelt_to_string
                                            impl
                                           in
                                        FStar_Util.print1
                                          "Implementation of a discriminator %s\n"
                                          uu____7952
                                    | uu____7953 -> ());
                                   [decl; impl])))
                         in
                      let arg_exp =
                        FStar_Syntax_Syntax.bv_to_name (Prims.fst arg_binder)
                         in
                      let binders =
                        FStar_List.append imp_binders [arg_binder]  in
                      let arg =
                        FStar_Syntax_Util.arg_of_non_null_binder arg_binder
                         in
                      let subst =
                        FStar_All.pipe_right fields
                          (FStar_List.mapi
                             (fun i  ->
                                fun uu____7972  ->
                                  match uu____7972 with
                                  | (a,uu____7976) ->
                                      let uu____7977 =
                                        FStar_Syntax_Util.mk_field_projector_name
                                          lid a i
                                         in
                                      (match uu____7977 with
                                       | (field_name,uu____7981) ->
                                           let field_proj_tm =
                                             let uu____7983 =
                                               let uu____7984 =
                                                 FStar_Syntax_Syntax.lid_as_fv
                                                   field_name
                                                   FStar_Syntax_Syntax.Delta_equational
                                                   None
                                                  in
                                               FStar_Syntax_Syntax.fv_to_tm
                                                 uu____7984
                                                in
                                             FStar_Syntax_Syntax.mk_Tm_uinst
                                               uu____7983 inst_univs
                                              in
                                           let proj =
                                             (FStar_Syntax_Syntax.mk_Tm_app
                                                field_proj_tm [arg]) None p
                                              in
                                           FStar_Syntax_Syntax.NT (a, proj))))
                         in
                      let projectors_ses =
                        let uu____8000 =
                          FStar_All.pipe_right fields
                            (FStar_List.mapi
                               (fun i  ->
                                  fun uu____8009  ->
                                    match uu____8009 with
                                    | (x,uu____8014) ->
                                        let p =
                                          FStar_Syntax_Syntax.range_of_bv x
                                           in
                                        let uu____8016 =
                                          FStar_Syntax_Util.mk_field_projector_name
                                            lid x i
                                           in
                                        (match uu____8016 with
                                         | (field_name,uu____8021) ->
                                             let t =
                                               let uu____8023 =
                                                 let uu____8024 =
                                                   let uu____8027 =
                                                     FStar_Syntax_Subst.subst
                                                       subst
                                                       x.FStar_Syntax_Syntax.sort
                                                      in
                                                   FStar_Syntax_Syntax.mk_Total
                                                     uu____8027
                                                    in
                                                 FStar_Syntax_Util.arrow
                                                   binders uu____8024
                                                  in
                                               FStar_All.pipe_left
                                                 (FStar_Syntax_Subst.close_univ_vars
                                                    uvs) uu____8023
                                                in
                                             let only_decl =
                                               ((let uu____8029 =
                                                   FStar_TypeChecker_Env.current_module
                                                     env
                                                    in
                                                 FStar_Ident.lid_equals
                                                   FStar_Syntax_Const.prims_lid
                                                   uu____8029)
                                                  ||
                                                  (fvq <>
                                                     FStar_Syntax_Syntax.Data_ctor))
                                                 ||
                                                 (let uu____8030 =
                                                    let uu____8031 =
                                                      FStar_TypeChecker_Env.current_module
                                                        env
                                                       in
                                                    uu____8031.FStar_Ident.str
                                                     in
                                                  FStar_Options.dont_gen_projectors
                                                    uu____8030)
                                                in
                                             let no_decl = false  in
                                             let quals q =
                                               match only_decl with
                                               | true  ->
                                                   let uu____8041 =
                                                     FStar_List.filter
                                                       (fun uu___107_8043  ->
                                                          match uu___107_8043
                                                          with
                                                          | FStar_Syntax_Syntax.Abstract
                                                               -> false
                                                          | uu____8044 ->
                                                              true) q
                                                      in
                                                   FStar_Syntax_Syntax.Assumption
                                                     :: uu____8041
                                               | uu____8045 -> q  in
                                             let quals =
                                               let iquals =
                                                 FStar_All.pipe_right iquals
                                                   (FStar_List.filter
                                                      (fun uu___108_8052  ->
                                                         match uu___108_8052
                                                         with
                                                         | FStar_Syntax_Syntax.Abstract
                                                           
                                                           |FStar_Syntax_Syntax.Private
                                                            -> true
                                                         | uu____8053 ->
                                                             false))
                                                  in
                                               quals
                                                 ((FStar_Syntax_Syntax.Projector
                                                     (lid,
                                                       (x.FStar_Syntax_Syntax.ppname)))
                                                 :: iquals)
                                                in
                                             let decl =
                                               FStar_Syntax_Syntax.Sig_declare_typ
                                                 (field_name, uvs, t, quals,
                                                   (FStar_Ident.range_of_lid
                                                      field_name))
                                                in
                                             ((let uu____8057 =
                                                 FStar_TypeChecker_Env.debug
                                                   env
                                                   (FStar_Options.Other
                                                      "LogTypes")
                                                  in
                                               match uu____8057 with
                                               | true  ->
                                                   let uu____8058 =
                                                     FStar_Syntax_Print.sigelt_to_string
                                                       decl
                                                      in
                                                   FStar_Util.print1
                                                     "Declaration of a projector %s\n"
                                                     uu____8058
                                               | uu____8059 -> ());
                                              (match only_decl with
                                               | true  -> [decl]
                                               | uu____8061 ->
                                                   let projection =
                                                     FStar_Syntax_Syntax.gen_bv
                                                       (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
                                                       None
                                                       FStar_Syntax_Syntax.tun
                                                      in
                                                   let arg_pats =
                                                     FStar_All.pipe_right
                                                       all_params
                                                       (FStar_List.mapi
                                                          (fun j  ->
                                                             fun uu____8085 
                                                               ->
                                                               match uu____8085
                                                               with
                                                               | (x,imp) ->
                                                                   let b =
                                                                    FStar_Syntax_Syntax.is_implicit
                                                                    imp  in
                                                                   (match 
                                                                    (i + ntps)
                                                                    = j
                                                                    with
                                                                    | 
                                                                    true  ->
                                                                    let uu____8101
                                                                    =
                                                                    pos
                                                                    (FStar_Syntax_Syntax.Pat_var
                                                                    projection)
                                                                     in
                                                                    (uu____8101,
                                                                    b)
                                                                    | 
                                                                    uu____8106
                                                                    ->
                                                                    (match 
                                                                    b &&
                                                                    (j < ntps)
                                                                    with
                                                                    | 
                                                                    true  ->
                                                                    let uu____8113
                                                                    =
                                                                    let uu____8116
                                                                    =
                                                                    let uu____8117
                                                                    =
                                                                    let uu____8122
                                                                    =
                                                                    FStar_Syntax_Syntax.gen_bv
                                                                    (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
                                                                    None
                                                                    FStar_Syntax_Syntax.tun
                                                                     in
                                                                    (uu____8122,
                                                                    FStar_Syntax_Syntax.tun)
                                                                     in
                                                                    FStar_Syntax_Syntax.Pat_dot_term
                                                                    uu____8117
                                                                     in
                                                                    pos
                                                                    uu____8116
                                                                     in
                                                                    (uu____8113,
                                                                    b)
                                                                    | 
                                                                    uu____8125
                                                                    ->
                                                                    let uu____8126
                                                                    =
                                                                    let uu____8129
                                                                    =
                                                                    let uu____8130
                                                                    =
                                                                    FStar_Syntax_Syntax.gen_bv
                                                                    (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
                                                                    None
                                                                    FStar_Syntax_Syntax.tun
                                                                     in
                                                                    FStar_Syntax_Syntax.Pat_wild
                                                                    uu____8130
                                                                     in
                                                                    pos
                                                                    uu____8129
                                                                     in
                                                                    (uu____8126,
                                                                    b)))))
                                                      in
                                                   let pat =
                                                     let uu____8142 =
                                                       let uu____8145 =
                                                         let uu____8146 =
                                                           let uu____8154 =
                                                             FStar_Syntax_Syntax.lid_as_fv
                                                               lid
                                                               FStar_Syntax_Syntax.Delta_constant
                                                               (Some fvq)
                                                              in
                                                           (uu____8154,
                                                             arg_pats)
                                                            in
                                                         FStar_Syntax_Syntax.Pat_cons
                                                           uu____8146
                                                          in
                                                       pos uu____8145  in
                                                     let uu____8160 =
                                                       FStar_Syntax_Syntax.bv_to_name
                                                         projection
                                                        in
                                                     (uu____8142, None,
                                                       uu____8160)
                                                      in
                                                   let body =
                                                     let uu____8171 =
                                                       let uu____8174 =
                                                         let uu____8175 =
                                                           let uu____8191 =
                                                             let uu____8193 =
                                                               FStar_Syntax_Util.branch
                                                                 pat
                                                                in
                                                             [uu____8193]  in
                                                           (arg_exp,
                                                             uu____8191)
                                                            in
                                                         FStar_Syntax_Syntax.Tm_match
                                                           uu____8175
                                                          in
                                                       FStar_Syntax_Syntax.mk
                                                         uu____8174
                                                        in
                                                     uu____8171 None p  in
                                                   let imp =
                                                     FStar_Syntax_Util.abs
                                                       binders body None
                                                      in
                                                   let dd =
                                                     let uu____8210 =
                                                       FStar_All.pipe_right
                                                         quals
                                                         (FStar_List.contains
                                                            FStar_Syntax_Syntax.Abstract)
                                                        in
                                                     match uu____8210 with
                                                     | true  ->
                                                         FStar_Syntax_Syntax.Delta_abstract
                                                           FStar_Syntax_Syntax.Delta_equational
                                                     | uu____8212 ->
                                                         FStar_Syntax_Syntax.Delta_equational
                                                      in
                                                   let lbtyp =
                                                     match no_decl with
                                                     | true  -> t
                                                     | uu____8214 ->
                                                         FStar_Syntax_Syntax.tun
                                                      in
                                                   let lb =
                                                     let uu____8216 =
                                                       let uu____8219 =
                                                         FStar_Syntax_Syntax.lid_as_fv
                                                           field_name dd None
                                                          in
                                                       FStar_Util.Inr
                                                         uu____8219
                                                        in
                                                     let uu____8220 =
                                                       FStar_Syntax_Subst.close_univ_vars
                                                         uvs imp
                                                        in
                                                     {
                                                       FStar_Syntax_Syntax.lbname
                                                         = uu____8216;
                                                       FStar_Syntax_Syntax.lbunivs
                                                         = uvs;
                                                       FStar_Syntax_Syntax.lbtyp
                                                         = lbtyp;
                                                       FStar_Syntax_Syntax.lbeff
                                                         =
                                                         FStar_Syntax_Const.effect_Tot_lid;
                                                       FStar_Syntax_Syntax.lbdef
                                                         = uu____8220
                                                     }  in
                                                   let impl =
                                                     let uu____8224 =
                                                       let uu____8233 =
                                                         let uu____8235 =
                                                           let uu____8236 =
                                                             FStar_All.pipe_right
                                                               lb.FStar_Syntax_Syntax.lbname
                                                               FStar_Util.right
                                                              in
                                                           FStar_All.pipe_right
                                                             uu____8236
                                                             (fun fv  ->
                                                                (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)
                                                            in
                                                         [uu____8235]  in
                                                       ((false, [lb]), p,
                                                         uu____8233, quals,
                                                         [])
                                                        in
                                                     FStar_Syntax_Syntax.Sig_let
                                                       uu____8224
                                                      in
                                                   ((let uu____8252 =
                                                       FStar_TypeChecker_Env.debug
                                                         env
                                                         (FStar_Options.Other
                                                            "LogTypes")
                                                        in
                                                     match uu____8252 with
                                                     | true  ->
                                                         let uu____8253 =
                                                           FStar_Syntax_Print.sigelt_to_string
                                                             impl
                                                            in
                                                         FStar_Util.print1
                                                           "Implementation of a projector %s\n"
                                                           uu____8253
                                                     | uu____8254 -> ());
                                                    (match no_decl with
                                                     | true  -> [impl]
                                                     | uu____8256 ->
                                                         [decl; impl])))))))
                           in
                        FStar_All.pipe_right uu____8000 FStar_List.flatten
                         in
                      FStar_List.append discriminator_ses projectors_ses
  
let mk_data_operations :
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.sigelt Prims.list ->
        FStar_Syntax_Syntax.sigelt -> FStar_Syntax_Syntax.sigelt Prims.list
  =
  fun iquals  ->
    fun env  ->
      fun tcs  ->
        fun se  ->
          match se with
          | FStar_Syntax_Syntax.Sig_datacon
              (constr_lid,uvs,t,typ_lid,n_typars,quals,uu____8284,r) when
              Prims.op_Negation
                (FStar_Ident.lid_equals constr_lid
                   FStar_Syntax_Const.lexcons_lid)
              ->
              let uu____8290 = FStar_Syntax_Subst.univ_var_opening uvs  in
              (match uu____8290 with
               | (univ_opening,uvs) ->
                   let t = FStar_Syntax_Subst.subst univ_opening t  in
                   let uu____8303 = FStar_Syntax_Util.arrow_formals t  in
                   (match uu____8303 with
                    | (formals,uu____8313) ->
                        let uu____8324 =
                          let tps_opt =
                            FStar_Util.find_map tcs
                              (fun se  ->
                                 let uu____8337 =
                                   let uu____8338 =
                                     let uu____8339 =
                                       FStar_Syntax_Util.lid_of_sigelt se  in
                                     FStar_Util.must uu____8339  in
                                   FStar_Ident.lid_equals typ_lid uu____8338
                                    in
                                 match uu____8337 with
                                 | true  ->
                                     (match se with
                                      | FStar_Syntax_Syntax.Sig_inductive_typ
                                          (uu____8349,uvs',tps,typ0,uu____8353,constrs,uu____8355,uu____8356)
                                          ->
                                          Some
                                            (tps, typ0,
                                              ((FStar_List.length constrs) >
                                                 (Prims.parse_int "1")))
                                      | uu____8370 -> failwith "Impossible")
                                 | uu____8375 -> None)
                             in
                          match tps_opt with
                          | Some x -> x
                          | None  ->
                              (match FStar_Ident.lid_equals typ_lid
                                       FStar_Syntax_Const.exn_lid
                               with
                               | true  ->
                                   ([], FStar_Syntax_Util.ktype0, true)
                               | uu____8402 ->
                                   Prims.raise
                                     (FStar_Errors.Error
                                        ("Unexpected data constructor", r)))
                           in
                        (match uu____8324 with
                         | (inductive_tps,typ0,should_refine) ->
                             let inductive_tps =
                               FStar_Syntax_Subst.subst_binders univ_opening
                                 inductive_tps
                                in
                             let typ0 =
                               FStar_Syntax_Subst.subst univ_opening typ0  in
                             let uu____8412 =
                               FStar_Syntax_Util.arrow_formals typ0  in
                             (match uu____8412 with
                              | (indices,uu____8422) ->
                                  let refine_domain =
                                    let uu____8434 =
                                      FStar_All.pipe_right quals
                                        (FStar_Util.for_some
                                           (fun uu___109_8436  ->
                                              match uu___109_8436 with
                                              | FStar_Syntax_Syntax.RecordConstructor
                                                  uu____8437 -> true
                                              | uu____8442 -> false))
                                       in
                                    match uu____8434 with
                                    | true  -> false
                                    | uu____8443 -> should_refine  in
                                  let fv_qual =
                                    let filter_records uu___110_8449 =
                                      match uu___110_8449 with
                                      | FStar_Syntax_Syntax.RecordConstructor
                                          (uu____8451,fns) ->
                                          Some
                                            (FStar_Syntax_Syntax.Record_ctor
                                               (constr_lid, fns))
                                      | uu____8458 -> None  in
                                    let uu____8459 =
                                      FStar_Util.find_map quals
                                        filter_records
                                       in
                                    match uu____8459 with
                                    | None  -> FStar_Syntax_Syntax.Data_ctor
                                    | Some q -> q  in
                                  let iquals =
                                    match FStar_List.contains
                                            FStar_Syntax_Syntax.Abstract
                                            iquals
                                    with
                                    | true  -> FStar_Syntax_Syntax.Private ::
                                        iquals
                                    | uu____8465 -> iquals  in
                                  let fields =
                                    let uu____8467 =
                                      FStar_Util.first_N n_typars formals  in
                                    match uu____8467 with
                                    | (imp_tps,fields) ->
                                        let rename =
                                          FStar_List.map2
                                            (fun uu____8498  ->
                                               fun uu____8499  ->
                                                 match (uu____8498,
                                                         uu____8499)
                                                 with
                                                 | ((x,uu____8509),(x',uu____8511))
                                                     ->
                                                     let uu____8516 =
                                                       let uu____8521 =
                                                         FStar_Syntax_Syntax.bv_to_name
                                                           x'
                                                          in
                                                       (x, uu____8521)  in
                                                     FStar_Syntax_Syntax.NT
                                                       uu____8516) imp_tps
                                            inductive_tps
                                           in
                                        FStar_Syntax_Subst.subst_binders
                                          rename fields
                                     in
                                  mk_discriminator_and_indexed_projectors
                                    iquals fv_qual refine_domain env typ_lid
                                    constr_lid uvs inductive_tps indices
                                    fields))))
          | uu____8522 -> []
  