open Prims
type decl =
  | DGlobal of (flag Prims.list * (Prims.string Prims.list * Prims.string) *
  typ * expr) 
  | DFunction of (cc Prims.option * flag Prims.list * Prims.int * typ *
  (Prims.string Prims.list * Prims.string) * binder Prims.list * expr) 
  | DTypeAlias of ((Prims.string Prims.list * Prims.string) * Prims.int *
  typ) 
  | DTypeFlat of ((Prims.string Prims.list * Prims.string) * Prims.int *
  (Prims.string * (typ * Prims.bool)) Prims.list) 
  | DExternal of (cc Prims.option * (Prims.string Prims.list * Prims.string)
  * typ) 
  | DTypeVariant of ((Prims.string Prims.list * Prims.string) * Prims.int *
  (Prims.string * (Prims.string * (typ * Prims.bool)) Prims.list) Prims.list) 
and cc =
  | StdCall 
  | CDecl 
  | FastCall 
and flag =
  | Private 
  | NoExtract 
  | CInline 
  | Substitute 
and lifetime =
  | Eternal 
  | Stack 
and expr =
  | EBound of Prims.int 
  | EQualified of (Prims.string Prims.list * Prims.string) 
  | EConstant of (width * Prims.string) 
  | EUnit 
  | EApp of (expr * expr Prims.list) 
  | ELet of (binder * expr * expr) 
  | EIfThenElse of (expr * expr * expr) 
  | ESequence of expr Prims.list 
  | EAssign of (expr * expr) 
  | EBufCreate of (lifetime * expr * expr) 
  | EBufRead of (expr * expr) 
  | EBufWrite of (expr * expr * expr) 
  | EBufSub of (expr * expr) 
  | EBufBlit of (expr * expr * expr * expr * expr) 
  | EMatch of (expr * (pattern * expr) Prims.list) 
  | EOp of (op * width) 
  | ECast of (expr * typ) 
  | EPushFrame 
  | EPopFrame 
  | EBool of Prims.bool 
  | EAny 
  | EAbort 
  | EReturn of expr 
  | EFlat of (typ * (Prims.string * expr) Prims.list) 
  | EField of (typ * expr * Prims.string) 
  | EWhile of (expr * expr) 
  | EBufCreateL of (lifetime * expr Prims.list) 
  | ETuple of expr Prims.list 
  | ECons of (typ * Prims.string * expr Prims.list) 
  | EBufFill of (expr * expr * expr) 
  | EString of Prims.string 
  | EFun of (binder Prims.list * expr) 
and op =
  | Add 
  | AddW 
  | Sub 
  | SubW 
  | Div 
  | DivW 
  | Mult 
  | MultW 
  | Mod 
  | BOr 
  | BAnd 
  | BXor 
  | BShiftL 
  | BShiftR 
  | BNot 
  | Eq 
  | Neq 
  | Lt 
  | Lte 
  | Gt 
  | Gte 
  | And 
  | Or 
  | Xor 
  | Not 
and pattern =
  | PUnit 
  | PBool of Prims.bool 
  | PVar of binder 
  | PCons of (Prims.string * pattern Prims.list) 
  | PTuple of pattern Prims.list 
  | PRecord of (Prims.string * pattern) Prims.list 
and width =
  | UInt8 
  | UInt16 
  | UInt32 
  | UInt64 
  | Int8 
  | Int16 
  | Int32 
  | Int64 
  | Bool 
  | Int 
  | UInt 
and binder = {
  name: Prims.string ;
  typ: typ ;
  mut: Prims.bool }
and typ =
  | TInt of width 
  | TBuf of typ 
  | TUnit 
  | TQualified of (Prims.string Prims.list * Prims.string) 
  | TBool 
  | TAny 
  | TArrow of (typ * typ) 
  | TZ 
  | TBound of Prims.int 
  | TApp of ((Prims.string Prims.list * Prims.string) * typ Prims.list) 
  | TTuple of typ Prims.list 
let uu___is_DGlobal : decl -> Prims.bool =
  fun projectee  ->
    match projectee with | DGlobal _0 -> true | uu____300 -> false
  
let __proj__DGlobal__item___0 :
  decl ->
    (flag Prims.list * (Prims.string Prims.list * Prims.string) * typ * expr)
  = fun projectee  -> match projectee with | DGlobal _0 -> _0 
let uu___is_DFunction : decl -> Prims.bool =
  fun projectee  ->
    match projectee with | DFunction _0 -> true | uu____349 -> false
  
let __proj__DFunction__item___0 :
  decl ->
    (cc Prims.option * flag Prims.list * Prims.int * typ * (Prims.string
      Prims.list * Prims.string) * binder Prims.list * expr)
  = fun projectee  -> match projectee with | DFunction _0 -> _0 
let uu___is_DTypeAlias : decl -> Prims.bool =
  fun projectee  ->
    match projectee with | DTypeAlias _0 -> true | uu____406 -> false
  
let __proj__DTypeAlias__item___0 :
  decl -> ((Prims.string Prims.list * Prims.string) * Prims.int * typ) =
  fun projectee  -> match projectee with | DTypeAlias _0 -> _0 
let uu___is_DTypeFlat : decl -> Prims.bool =
  fun projectee  ->
    match projectee with | DTypeFlat _0 -> true | uu____447 -> false
  
let __proj__DTypeFlat__item___0 :
  decl ->
    ((Prims.string Prims.list * Prims.string) * Prims.int * (Prims.string *
      (typ * Prims.bool)) Prims.list)
  = fun projectee  -> match projectee with | DTypeFlat _0 -> _0 
let uu___is_DExternal : decl -> Prims.bool =
  fun projectee  ->
    match projectee with | DExternal _0 -> true | uu____499 -> false
  
let __proj__DExternal__item___0 :
  decl -> (cc Prims.option * (Prims.string Prims.list * Prims.string) * typ)
  = fun projectee  -> match projectee with | DExternal _0 -> _0 
let uu___is_DTypeVariant : decl -> Prims.bool =
  fun projectee  ->
    match projectee with | DTypeVariant _0 -> true | uu____546 -> false
  
let __proj__DTypeVariant__item___0 :
  decl ->
    ((Prims.string Prims.list * Prims.string) * Prims.int * (Prims.string *
      (Prims.string * (typ * Prims.bool)) Prims.list) Prims.list)
  = fun projectee  -> match projectee with | DTypeVariant _0 -> _0 
let uu___is_StdCall : cc -> Prims.bool =
  fun projectee  ->
    match projectee with | StdCall  -> true | uu____599 -> false
  
let uu___is_CDecl : cc -> Prims.bool =
  fun projectee  ->
    match projectee with | CDecl  -> true | uu____603 -> false
  
let uu___is_FastCall : cc -> Prims.bool =
  fun projectee  ->
    match projectee with | FastCall  -> true | uu____607 -> false
  
let uu___is_Private : flag -> Prims.bool =
  fun projectee  ->
    match projectee with | Private  -> true | uu____611 -> false
  
let uu___is_NoExtract : flag -> Prims.bool =
  fun projectee  ->
    match projectee with | NoExtract  -> true | uu____615 -> false
  
let uu___is_CInline : flag -> Prims.bool =
  fun projectee  ->
    match projectee with | CInline  -> true | uu____619 -> false
  
let uu___is_Substitute : flag -> Prims.bool =
  fun projectee  ->
    match projectee with | Substitute  -> true | uu____623 -> false
  
let uu___is_Eternal : lifetime -> Prims.bool =
  fun projectee  ->
    match projectee with | Eternal  -> true | uu____627 -> false
  
let uu___is_Stack : lifetime -> Prims.bool =
  fun projectee  ->
    match projectee with | Stack  -> true | uu____631 -> false
  
let uu___is_EBound : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EBound _0 -> true | uu____636 -> false
  
let __proj__EBound__item___0 : expr -> Prims.int =
  fun projectee  -> match projectee with | EBound _0 -> _0 
let uu___is_EQualified : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EQualified _0 -> true | uu____651 -> false
  
let __proj__EQualified__item___0 :
  expr -> (Prims.string Prims.list * Prims.string) =
  fun projectee  -> match projectee with | EQualified _0 -> _0 
let uu___is_EConstant : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EConstant _0 -> true | uu____674 -> false
  
let __proj__EConstant__item___0 : expr -> (width * Prims.string) =
  fun projectee  -> match projectee with | EConstant _0 -> _0 
let uu___is_EUnit : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EUnit  -> true | uu____691 -> false
  
let uu___is_EApp : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EApp _0 -> true | uu____699 -> false
  
let __proj__EApp__item___0 : expr -> (expr * expr Prims.list) =
  fun projectee  -> match projectee with | EApp _0 -> _0 
let uu___is_ELet : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | ELet _0 -> true | uu____723 -> false
  
let __proj__ELet__item___0 : expr -> (binder * expr * expr) =
  fun projectee  -> match projectee with | ELet _0 -> _0 
let uu___is_EIfThenElse : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EIfThenElse _0 -> true | uu____747 -> false
  
let __proj__EIfThenElse__item___0 : expr -> (expr * expr * expr) =
  fun projectee  -> match projectee with | EIfThenElse _0 -> _0 
let uu___is_ESequence : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | ESequence _0 -> true | uu____769 -> false
  
let __proj__ESequence__item___0 : expr -> expr Prims.list =
  fun projectee  -> match projectee with | ESequence _0 -> _0 
let uu___is_EAssign : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EAssign _0 -> true | uu____786 -> false
  
let __proj__EAssign__item___0 : expr -> (expr * expr) =
  fun projectee  -> match projectee with | EAssign _0 -> _0 
let uu___is_EBufCreate : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EBufCreate _0 -> true | uu____807 -> false
  
let __proj__EBufCreate__item___0 : expr -> (lifetime * expr * expr) =
  fun projectee  -> match projectee with | EBufCreate _0 -> _0 
let uu___is_EBufRead : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EBufRead _0 -> true | uu____830 -> false
  
let __proj__EBufRead__item___0 : expr -> (expr * expr) =
  fun projectee  -> match projectee with | EBufRead _0 -> _0 
let uu___is_EBufWrite : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EBufWrite _0 -> true | uu____851 -> false
  
let __proj__EBufWrite__item___0 : expr -> (expr * expr * expr) =
  fun projectee  -> match projectee with | EBufWrite _0 -> _0 
let uu___is_EBufSub : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EBufSub _0 -> true | uu____874 -> false
  
let __proj__EBufSub__item___0 : expr -> (expr * expr) =
  fun projectee  -> match projectee with | EBufSub _0 -> _0 
let uu___is_EBufBlit : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EBufBlit _0 -> true | uu____897 -> false
  
let __proj__EBufBlit__item___0 : expr -> (expr * expr * expr * expr * expr) =
  fun projectee  -> match projectee with | EBufBlit _0 -> _0 
let uu___is_EMatch : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EMatch _0 -> true | uu____929 -> false
  
let __proj__EMatch__item___0 : expr -> (expr * (pattern * expr) Prims.list) =
  fun projectee  -> match projectee with | EMatch _0 -> _0 
let uu___is_EOp : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EOp _0 -> true | uu____958 -> false
  
let __proj__EOp__item___0 : expr -> (op * width) =
  fun projectee  -> match projectee with | EOp _0 -> _0 
let uu___is_ECast : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | ECast _0 -> true | uu____978 -> false
  
let __proj__ECast__item___0 : expr -> (expr * typ) =
  fun projectee  -> match projectee with | ECast _0 -> _0 
let uu___is_EPushFrame : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EPushFrame  -> true | uu____995 -> false
  
let uu___is_EPopFrame : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EPopFrame  -> true | uu____999 -> false
  
let uu___is_EBool : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EBool _0 -> true | uu____1004 -> false
  
let __proj__EBool__item___0 : expr -> Prims.bool =
  fun projectee  -> match projectee with | EBool _0 -> _0 
let uu___is_EAny : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EAny  -> true | uu____1015 -> false
  
let uu___is_EAbort : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EAbort  -> true | uu____1019 -> false
  
let uu___is_EReturn : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EReturn _0 -> true | uu____1024 -> false
  
let __proj__EReturn__item___0 : expr -> expr =
  fun projectee  -> match projectee with | EReturn _0 -> _0 
let uu___is_EFlat : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EFlat _0 -> true | uu____1041 -> false
  
let __proj__EFlat__item___0 :
  expr -> (typ * (Prims.string * expr) Prims.list) =
  fun projectee  -> match projectee with | EFlat _0 -> _0 
let uu___is_EField : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EField _0 -> true | uu____1071 -> false
  
let __proj__EField__item___0 : expr -> (typ * expr * Prims.string) =
  fun projectee  -> match projectee with | EField _0 -> _0 
let uu___is_EWhile : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EWhile _0 -> true | uu____1094 -> false
  
let __proj__EWhile__item___0 : expr -> (expr * expr) =
  fun projectee  -> match projectee with | EWhile _0 -> _0 
let uu___is_EBufCreateL : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EBufCreateL _0 -> true | uu____1115 -> false
  
let __proj__EBufCreateL__item___0 : expr -> (lifetime * expr Prims.list) =
  fun projectee  -> match projectee with | EBufCreateL _0 -> _0 
let uu___is_ETuple : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | ETuple _0 -> true | uu____1137 -> false
  
let __proj__ETuple__item___0 : expr -> expr Prims.list =
  fun projectee  -> match projectee with | ETuple _0 -> _0 
let uu___is_ECons : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | ECons _0 -> true | uu____1156 -> false
  
let __proj__ECons__item___0 : expr -> (typ * Prims.string * expr Prims.list)
  = fun projectee  -> match projectee with | ECons _0 -> _0 
let uu___is_EBufFill : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EBufFill _0 -> true | uu____1183 -> false
  
let __proj__EBufFill__item___0 : expr -> (expr * expr * expr) =
  fun projectee  -> match projectee with | EBufFill _0 -> _0 
let uu___is_EString : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EString _0 -> true | uu____1204 -> false
  
let __proj__EString__item___0 : expr -> Prims.string =
  fun projectee  -> match projectee with | EString _0 -> _0 
let uu___is_EFun : expr -> Prims.bool =
  fun projectee  ->
    match projectee with | EFun _0 -> true | uu____1219 -> false
  
let __proj__EFun__item___0 : expr -> (binder Prims.list * expr) =
  fun projectee  -> match projectee with | EFun _0 -> _0 
let uu___is_Add : op -> Prims.bool =
  fun projectee  -> match projectee with | Add  -> true | uu____1239 -> false 
let uu___is_AddW : op -> Prims.bool =
  fun projectee  ->
    match projectee with | AddW  -> true | uu____1243 -> false
  
let uu___is_Sub : op -> Prims.bool =
  fun projectee  -> match projectee with | Sub  -> true | uu____1247 -> false 
let uu___is_SubW : op -> Prims.bool =
  fun projectee  ->
    match projectee with | SubW  -> true | uu____1251 -> false
  
let uu___is_Div : op -> Prims.bool =
  fun projectee  -> match projectee with | Div  -> true | uu____1255 -> false 
let uu___is_DivW : op -> Prims.bool =
  fun projectee  ->
    match projectee with | DivW  -> true | uu____1259 -> false
  
let uu___is_Mult : op -> Prims.bool =
  fun projectee  ->
    match projectee with | Mult  -> true | uu____1263 -> false
  
let uu___is_MultW : op -> Prims.bool =
  fun projectee  ->
    match projectee with | MultW  -> true | uu____1267 -> false
  
let uu___is_Mod : op -> Prims.bool =
  fun projectee  -> match projectee with | Mod  -> true | uu____1271 -> false 
let uu___is_BOr : op -> Prims.bool =
  fun projectee  -> match projectee with | BOr  -> true | uu____1275 -> false 
let uu___is_BAnd : op -> Prims.bool =
  fun projectee  ->
    match projectee with | BAnd  -> true | uu____1279 -> false
  
let uu___is_BXor : op -> Prims.bool =
  fun projectee  ->
    match projectee with | BXor  -> true | uu____1283 -> false
  
let uu___is_BShiftL : op -> Prims.bool =
  fun projectee  ->
    match projectee with | BShiftL  -> true | uu____1287 -> false
  
let uu___is_BShiftR : op -> Prims.bool =
  fun projectee  ->
    match projectee with | BShiftR  -> true | uu____1291 -> false
  
let uu___is_BNot : op -> Prims.bool =
  fun projectee  ->
    match projectee with | BNot  -> true | uu____1295 -> false
  
let uu___is_Eq : op -> Prims.bool =
  fun projectee  -> match projectee with | Eq  -> true | uu____1299 -> false 
let uu___is_Neq : op -> Prims.bool =
  fun projectee  -> match projectee with | Neq  -> true | uu____1303 -> false 
let uu___is_Lt : op -> Prims.bool =
  fun projectee  -> match projectee with | Lt  -> true | uu____1307 -> false 
let uu___is_Lte : op -> Prims.bool =
  fun projectee  -> match projectee with | Lte  -> true | uu____1311 -> false 
let uu___is_Gt : op -> Prims.bool =
  fun projectee  -> match projectee with | Gt  -> true | uu____1315 -> false 
let uu___is_Gte : op -> Prims.bool =
  fun projectee  -> match projectee with | Gte  -> true | uu____1319 -> false 
let uu___is_And : op -> Prims.bool =
  fun projectee  -> match projectee with | And  -> true | uu____1323 -> false 
let uu___is_Or : op -> Prims.bool =
  fun projectee  -> match projectee with | Or  -> true | uu____1327 -> false 
let uu___is_Xor : op -> Prims.bool =
  fun projectee  -> match projectee with | Xor  -> true | uu____1331 -> false 
let uu___is_Not : op -> Prims.bool =
  fun projectee  -> match projectee with | Not  -> true | uu____1335 -> false 
let uu___is_PUnit : pattern -> Prims.bool =
  fun projectee  ->
    match projectee with | PUnit  -> true | uu____1339 -> false
  
let uu___is_PBool : pattern -> Prims.bool =
  fun projectee  ->
    match projectee with | PBool _0 -> true | uu____1344 -> false
  
let __proj__PBool__item___0 : pattern -> Prims.bool =
  fun projectee  -> match projectee with | PBool _0 -> _0 
let uu___is_PVar : pattern -> Prims.bool =
  fun projectee  ->
    match projectee with | PVar _0 -> true | uu____1356 -> false
  
let __proj__PVar__item___0 : pattern -> binder =
  fun projectee  -> match projectee with | PVar _0 -> _0 
let uu___is_PCons : pattern -> Prims.bool =
  fun projectee  ->
    match projectee with | PCons _0 -> true | uu____1371 -> false
  
let __proj__PCons__item___0 : pattern -> (Prims.string * pattern Prims.list)
  = fun projectee  -> match projectee with | PCons _0 -> _0 
let uu___is_PTuple : pattern -> Prims.bool =
  fun projectee  ->
    match projectee with | PTuple _0 -> true | uu____1393 -> false
  
let __proj__PTuple__item___0 : pattern -> pattern Prims.list =
  fun projectee  -> match projectee with | PTuple _0 -> _0 
let uu___is_PRecord : pattern -> Prims.bool =
  fun projectee  ->
    match projectee with | PRecord _0 -> true | uu____1411 -> false
  
let __proj__PRecord__item___0 :
  pattern -> (Prims.string * pattern) Prims.list =
  fun projectee  -> match projectee with | PRecord _0 -> _0 
let uu___is_UInt8 : width -> Prims.bool =
  fun projectee  ->
    match projectee with | UInt8  -> true | uu____1431 -> false
  
let uu___is_UInt16 : width -> Prims.bool =
  fun projectee  ->
    match projectee with | UInt16  -> true | uu____1435 -> false
  
let uu___is_UInt32 : width -> Prims.bool =
  fun projectee  ->
    match projectee with | UInt32  -> true | uu____1439 -> false
  
let uu___is_UInt64 : width -> Prims.bool =
  fun projectee  ->
    match projectee with | UInt64  -> true | uu____1443 -> false
  
let uu___is_Int8 : width -> Prims.bool =
  fun projectee  ->
    match projectee with | Int8  -> true | uu____1447 -> false
  
let uu___is_Int16 : width -> Prims.bool =
  fun projectee  ->
    match projectee with | Int16  -> true | uu____1451 -> false
  
let uu___is_Int32 : width -> Prims.bool =
  fun projectee  ->
    match projectee with | Int32  -> true | uu____1455 -> false
  
let uu___is_Int64 : width -> Prims.bool =
  fun projectee  ->
    match projectee with | Int64  -> true | uu____1459 -> false
  
let uu___is_Bool : width -> Prims.bool =
  fun projectee  ->
    match projectee with | Bool  -> true | uu____1463 -> false
  
let uu___is_Int : width -> Prims.bool =
  fun projectee  -> match projectee with | Int  -> true | uu____1467 -> false 
let uu___is_UInt : width -> Prims.bool =
  fun projectee  ->
    match projectee with | UInt  -> true | uu____1471 -> false
  
let uu___is_TInt : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TInt _0 -> true | uu____1488 -> false
  
let __proj__TInt__item___0 : typ -> width =
  fun projectee  -> match projectee with | TInt _0 -> _0 
let uu___is_TBuf : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TBuf _0 -> true | uu____1500 -> false
  
let __proj__TBuf__item___0 : typ -> typ =
  fun projectee  -> match projectee with | TBuf _0 -> _0 
let uu___is_TUnit : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TUnit  -> true | uu____1511 -> false
  
let uu___is_TQualified : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TQualified _0 -> true | uu____1519 -> false
  
let __proj__TQualified__item___0 :
  typ -> (Prims.string Prims.list * Prims.string) =
  fun projectee  -> match projectee with | TQualified _0 -> _0 
let uu___is_TBool : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TBool  -> true | uu____1539 -> false
  
let uu___is_TAny : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TAny  -> true | uu____1543 -> false
  
let uu___is_TArrow : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TArrow _0 -> true | uu____1550 -> false
  
let __proj__TArrow__item___0 : typ -> (typ * typ) =
  fun projectee  -> match projectee with | TArrow _0 -> _0 
let uu___is_TZ : typ -> Prims.bool =
  fun projectee  -> match projectee with | TZ  -> true | uu____1567 -> false 
let uu___is_TBound : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TBound _0 -> true | uu____1572 -> false
  
let __proj__TBound__item___0 : typ -> Prims.int =
  fun projectee  -> match projectee with | TBound _0 -> _0 
let uu___is_TApp : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TApp _0 -> true | uu____1590 -> false
  
let __proj__TApp__item___0 :
  typ -> ((Prims.string Prims.list * Prims.string) * typ Prims.list) =
  fun projectee  -> match projectee with | TApp _0 -> _0 
let uu___is_TTuple : typ -> Prims.bool =
  fun projectee  ->
    match projectee with | TTuple _0 -> true | uu____1621 -> false
  
let __proj__TTuple__item___0 : typ -> typ Prims.list =
  fun projectee  -> match projectee with | TTuple _0 -> _0 
type program = decl Prims.list
type ident = Prims.string
type fields_t = (Prims.string * (typ * Prims.bool)) Prims.list
type branches_t =
  (Prims.string * (Prims.string * (typ * Prims.bool)) Prims.list) Prims.list
type branch = (pattern * expr)
type branches = (pattern * expr) Prims.list
type constant = (width * Prims.string)
type var = Prims.int
type lident = (Prims.string Prims.list * Prims.string)
type version = Prims.int
let current_version : Prims.int = (Prims.parse_int "20") 
type file = (Prims.string * program)
type binary_format = (version * file Prims.list)
let fst3 uu____1674 = match uu____1674 with | (x,uu____1679,uu____1680) -> x 
let snd3 uu____1694 = match uu____1694 with | (uu____1698,x,uu____1700) -> x 
let thd3 uu____1714 = match uu____1714 with | (uu____1718,uu____1719,x) -> x 
let mk_width : Prims.string -> width Prims.option =
  fun uu___114_1724  ->
    match uu___114_1724 with
    | "UInt8" -> Some UInt8
    | "UInt16" -> Some UInt16
    | "UInt32" -> Some UInt32
    | "UInt64" -> Some UInt64
    | "Int8" -> Some Int8
    | "Int16" -> Some Int16
    | "Int32" -> Some Int32
    | "Int64" -> Some Int64
    | uu____1726 -> None
  
let mk_bool_op : Prims.string -> op Prims.option =
  fun uu___115_1730  ->
    match uu___115_1730 with
    | "op_Negation" -> Some Not
    | "op_AmpAmp" -> Some And
    | "op_BarBar" -> Some Or
    | "op_Equality" -> Some Eq
    | "op_disEquality" -> Some Neq
    | uu____1732 -> None
  
let is_bool_op : Prims.string -> Prims.bool =
  fun op  -> (mk_bool_op op) <> None 
let mk_op : Prims.string -> op Prims.option =
  fun uu___116_1740  ->
    match uu___116_1740 with
    | "add"|"op_Plus_Hat" -> Some Add
    | "add_mod"|"op_Plus_Percent_Hat" -> Some AddW
    | "sub"|"op_Subtraction_Hat" -> Some Sub
    | "sub_mod"|"op_Subtraction_Percent_Hat" -> Some SubW
    | "mul"|"op_Star_Hat" -> Some Mult
    | "mul_mod"|"op_Star_Percent_Hat" -> Some MultW
    | "div"|"op_Slash_Hat" -> Some Div
    | "div_mod"|"op_Slash_Percent_Hat" -> Some DivW
    | "rem"|"op_Percent_Hat" -> Some Mod
    | "logor"|"op_Bar_Hat" -> Some BOr
    | "logxor"|"op_Hat_Hat" -> Some BXor
    | "logand"|"op_Amp_Hat" -> Some BAnd
    | "lognot" -> Some BNot
    | "shift_right"|"op_Greater_Greater_Hat" -> Some BShiftR
    | "shift_left"|"op_Less_Less_Hat" -> Some BShiftL
    | "eq"|"op_Equals_Hat" -> Some Eq
    | "op_Greater_Hat"|"gt" -> Some Gt
    | "op_Greater_Equals_Hat"|"gte" -> Some Gte
    | "op_Less_Hat"|"lt" -> Some Lt
    | "op_Less_Equals_Hat"|"lte" -> Some Lte
    | uu____1742 -> None
  
let is_op : Prims.string -> Prims.bool = fun op  -> (mk_op op) <> None 
let is_machine_int : Prims.string -> Prims.bool =
  fun m  -> (mk_width m) <> None 
type env =
  {
  names: name Prims.list ;
  names_t: Prims.string Prims.list ;
  module_name: Prims.string Prims.list }
and name = {
  pretty: Prims.string ;
  mut: Prims.bool }
let empty : Prims.string Prims.list -> env =
  fun module_name  -> { names = []; names_t = []; module_name } 
let extend : env -> Prims.string -> Prims.bool -> env =
  fun env  ->
    fun x  ->
      fun is_mut  ->
        let uu___121_1809 = env  in
        {
          names = ({ pretty = x; mut = is_mut } :: (env.names));
          names_t = (uu___121_1809.names_t);
          module_name = (uu___121_1809.module_name)
        }
  
let extend_t : env -> Prims.string -> env =
  fun env  ->
    fun x  ->
      let uu___122_1816 = env  in
      {
        names = (uu___122_1816.names);
        names_t = (x :: (env.names_t));
        module_name = (uu___122_1816.module_name)
      }
  
let find_name : env -> Prims.string -> name =
  fun env  ->
    fun x  ->
      let uu____1823 =
        FStar_List.tryFind (fun name  -> name.pretty = x) env.names  in
      match uu____1823 with
      | Some name -> name
      | None  -> failwith "internal error: name not found"
  
let is_mutable : env -> Prims.string -> Prims.bool =
  fun env  -> fun x  -> (find_name env x).mut 
let find : env -> Prims.string -> Prims.int =
  fun env  ->
    fun x  ->
      try FStar_List.index (fun name  -> name.pretty = x) env.names
      with
      | uu____1842 ->
          failwith
            (FStar_Util.format1 "Internal error: name not found %s\n" x)
  
let find_t : env -> Prims.string -> Prims.int =
  fun env  ->
    fun x  ->
      try FStar_List.index (fun name  -> name = x) env.names_t
      with
      | uu____1852 ->
          failwith
            (FStar_Util.format1 "Internal error: name not found %s\n" x)
  
let add_binders env binders =
  FStar_List.fold_left
    (fun env  ->
       fun uu____1882  ->
         match uu____1882 with
         | ((name,uu____1888),uu____1889) -> extend env name false) env
    binders
  
let rec translate : FStar_Extraction_ML_Syntax.mllib -> file Prims.list =
  fun uu____1980  ->
    match uu____1980 with
    | FStar_Extraction_ML_Syntax.MLLib modules ->
        FStar_List.filter_map
          (fun m  ->
             let m_name =
               let uu____2011 = m  in
               match uu____2011 with
               | ((prefix,final),uu____2023,uu____2024) ->
                   FStar_String.concat "." (FStar_List.append prefix [final])
                in
             try
               FStar_Util.print1 "Attempting to translate module %s\n" m_name;
               Some (translate_module m)
             with
             | e ->
                 ((let _0_344 = FStar_Util.print_exn e  in
                   FStar_Util.print2
                     "Unable to translate module: %s because:\n  %s\n" m_name
                     _0_344);
                  None)) modules

and translate_module :
  ((Prims.string Prims.list * Prims.string) *
    (FStar_Extraction_ML_Syntax.mlsig * FStar_Extraction_ML_Syntax.mlmodule)
    Prims.option * FStar_Extraction_ML_Syntax.mllib) -> file
  =
  fun uu____2044  ->
    match uu____2044 with
    | (module_name,modul,uu____2056) ->
        let module_name =
          FStar_List.append (Prims.fst module_name) [Prims.snd module_name]
           in
        let program =
          match modul with
          | Some (_signature,decls) ->
              FStar_List.filter_map (translate_decl (empty module_name))
                decls
          | uu____2080 ->
              failwith "Unexpected standalone interface or nested modules"
           in
        ((FStar_String.concat "_" module_name), program)

and translate_flags :
  FStar_Extraction_ML_Syntax.c_flag Prims.list -> flag Prims.list =
  fun flags  ->
    FStar_List.choose
      (fun uu___117_2088  ->
         match uu___117_2088 with
         | FStar_Extraction_ML_Syntax.Private  -> Some Private
         | FStar_Extraction_ML_Syntax.NoExtract  -> Some NoExtract
         | FStar_Extraction_ML_Syntax.Attribute "c_inline" -> Some CInline
         | FStar_Extraction_ML_Syntax.Attribute "substitute" ->
             Some Substitute
         | FStar_Extraction_ML_Syntax.Attribute a ->
             (FStar_Util.print1_warning "Warning: unrecognized attribute %s"
                a;
              None)
         | uu____2092 -> None) flags

and translate_decl :
  env -> FStar_Extraction_ML_Syntax.mlmodule1 -> decl Prims.option =
  fun env  ->
    fun d  ->
      match d with
      | FStar_Extraction_ML_Syntax.MLM_Let
        (flavor,flags,{ FStar_Extraction_ML_Syntax.mllb_name = (name,_);
                        FStar_Extraction_ML_Syntax.mllb_tysc = Some
                          (tvars,t0);
                        FStar_Extraction_ML_Syntax.mllb_add_unit = _;
                        FStar_Extraction_ML_Syntax.mllb_def =
                          {
                            FStar_Extraction_ML_Syntax.expr =
                              FStar_Extraction_ML_Syntax.MLE_Fun (args,body);
                            FStar_Extraction_ML_Syntax.mlty = _;
                            FStar_Extraction_ML_Syntax.loc = _;_};
                        FStar_Extraction_ML_Syntax.print_typ = _;_}::[])
        |FStar_Extraction_ML_Syntax.MLM_Let
        (flavor,flags,{ FStar_Extraction_ML_Syntax.mllb_name = (name,_);
                        FStar_Extraction_ML_Syntax.mllb_tysc = Some
                          (tvars,t0);
                        FStar_Extraction_ML_Syntax.mllb_add_unit = _;
                        FStar_Extraction_ML_Syntax.mllb_def =
                          {
                            FStar_Extraction_ML_Syntax.expr =
                              FStar_Extraction_ML_Syntax.MLE_Coerce
                              ({
                                 FStar_Extraction_ML_Syntax.expr =
                                   FStar_Extraction_ML_Syntax.MLE_Fun
                                   (args,body);
                                 FStar_Extraction_ML_Syntax.mlty = _;
                                 FStar_Extraction_ML_Syntax.loc = _;_},_,_);
                            FStar_Extraction_ML_Syntax.mlty = _;
                            FStar_Extraction_ML_Syntax.loc = _;_};
                        FStar_Extraction_ML_Syntax.print_typ = _;_}::[])
          ->
          let assumed =
            FStar_Util.for_some
              (fun uu___118_2137  ->
                 match uu___118_2137 with
                 | FStar_Extraction_ML_Syntax.Assumed  -> true
                 | uu____2138 -> false) flags
             in
          let env =
            if flavor = FStar_Extraction_ML_Syntax.Rec
            then extend env name false
            else env  in
          let env =
            FStar_List.fold_left
              (fun env  ->
                 fun uu____2145  ->
                   match uu____2145 with
                   | (name,uu____2149) -> extend_t env name) env tvars
             in
          let rec find_return_type uu___119_2153 =
            match uu___119_2153 with
            | FStar_Extraction_ML_Syntax.MLTY_Fun (uu____2154,uu____2155,t)
                -> find_return_type t
            | t -> t  in
          let t =
            let _0_345 = find_return_type t0  in translate_type env _0_345
             in
          let binders = translate_binders env args  in
          let env = add_binders env args  in
          let name = ((env.module_name), name)  in
          let flags = translate_flags flags  in
          if assumed
          then
            Some
              (DExternal
                 (let _0_346 = translate_type env t0  in (None, name, _0_346)))
          else
            (try
               let body = translate_expr env body  in
               Some
                 (DFunction
                    (None, flags, (FStar_List.length tvars), t, name,
                      binders, body))
             with
             | e ->
                 ((let _0_347 = FStar_Util.print_exn e  in
                   FStar_Util.print2 "Warning: writing a stub for %s (%s)\n"
                     (Prims.snd name) _0_347);
                  Some
                    (DFunction
                       (None, flags, (FStar_List.length tvars), t, name,
                         binders, EAbort))))
      | FStar_Extraction_ML_Syntax.MLM_Let
          (flavor,flags,{
                          FStar_Extraction_ML_Syntax.mllb_name =
                            (name,uu____2203);
                          FStar_Extraction_ML_Syntax.mllb_tysc = Some ([],t);
                          FStar_Extraction_ML_Syntax.mllb_add_unit =
                            uu____2205;
                          FStar_Extraction_ML_Syntax.mllb_def = expr;
                          FStar_Extraction_ML_Syntax.print_typ = uu____2207;_}::[])
          ->
          let flags = translate_flags flags  in
          let t = translate_type env t  in
          let name = ((env.module_name), name)  in
          (try
             let expr = translate_expr env expr  in
             Some (DGlobal (flags, name, t, expr))
           with
           | e ->
               ((let _0_348 = FStar_Util.print_exn e  in
                 FStar_Util.print2
                   "Warning: not translating definition for %s (%s)\n"
                   (Prims.snd name) _0_348);
                Some (DGlobal (flags, name, t, EAny))))
      | FStar_Extraction_ML_Syntax.MLM_Let
          (uu____2238,uu____2239,{
                                   FStar_Extraction_ML_Syntax.mllb_name =
                                     (name,uu____2241);
                                   FStar_Extraction_ML_Syntax.mllb_tysc = ts;
                                   FStar_Extraction_ML_Syntax.mllb_add_unit =
                                     uu____2243;
                                   FStar_Extraction_ML_Syntax.mllb_def =
                                     uu____2244;
                                   FStar_Extraction_ML_Syntax.print_typ =
                                     uu____2245;_}::uu____2246)
          ->
          (FStar_Util.print1
             "Warning: not translating definition for %s (and possibly others)\n"
             name;
           (match ts with
            | Some (idents,t) ->
                let _0_351 =
                  let _0_349 = FStar_List.map Prims.fst idents  in
                  FStar_String.concat ", " _0_349  in
                let _0_350 =
                  FStar_Extraction_ML_Code.string_of_mlty ([], "") t  in
                FStar_Util.print2 "Type scheme is: forall %s. %s\n" _0_351
                  _0_350
            | None  -> ());
           None)
      | FStar_Extraction_ML_Syntax.MLM_Let uu____2259 ->
          failwith "impossible"
      | FStar_Extraction_ML_Syntax.MLM_Loc uu____2261 -> None
      | FStar_Extraction_ML_Syntax.MLM_Ty
          ((assumed,name,_mangled_name,args,Some
            (FStar_Extraction_ML_Syntax.MLTD_Abbrev t))::[])
          ->
          let name = ((env.module_name), name)  in
          let env =
            FStar_List.fold_left
              (fun env  ->
                 fun uu____2293  ->
                   match uu____2293 with
                   | (name,uu____2297) -> extend_t env name) env args
             in
          if assumed
          then None
          else
            Some
              (DTypeAlias
                 ((let _0_352 = translate_type env t  in
                   (name, (FStar_List.length args), _0_352))))
      | FStar_Extraction_ML_Syntax.MLM_Ty
          ((uu____2305,name,_mangled_name,args,Some
            (FStar_Extraction_ML_Syntax.MLTD_Record fields))::[])
          ->
          let name = ((env.module_name), name)  in
          let env =
            FStar_List.fold_left
              (fun env  ->
                 fun uu____2339  ->
                   match uu____2339 with
                   | (name,uu____2343) -> extend_t env name) env args
             in
          Some
            (DTypeFlat
               (let _0_355 =
                  FStar_List.map
                    (fun uu____2360  ->
                       match uu____2360 with
                       | (f,t) ->
                           let _0_354 =
                             let _0_353 = translate_type env t  in
                             (_0_353, false)  in
                           (f, _0_354)) fields
                   in
                (name, (FStar_List.length args), _0_355)))
      | FStar_Extraction_ML_Syntax.MLM_Ty
          ((uu____2371,name,_mangled_name,args,Some
            (FStar_Extraction_ML_Syntax.MLTD_DType branches))::[])
          ->
          let name = ((env.module_name), name)  in
          let env =
            FStar_List.fold_left
              (fun env  ->
                 fun uu____2406  ->
                   match uu____2406 with
                   | (name,uu____2410) -> extend_t env name) env args
             in
          Some
            (DTypeVariant
               (let _0_362 =
                  FStar_List.mapi
                    (fun i  ->
                       fun uu____2435  ->
                         match uu____2435 with
                         | (cons,ts) ->
                             let _0_361 =
                               FStar_List.mapi
                                 (fun j  ->
                                    fun t  ->
                                      let _0_360 =
                                        let _0_357 =
                                          FStar_Util.string_of_int i  in
                                        let _0_356 =
                                          FStar_Util.string_of_int j  in
                                        FStar_Util.format2 "x%s%s" _0_357
                                          _0_356
                                         in
                                      let _0_359 =
                                        let _0_358 = translate_type env t  in
                                        (_0_358, false)  in
                                      (_0_360, _0_359)) ts
                                in
                             (cons, _0_361)) branches
                   in
                (name, (FStar_List.length args), _0_362)))
      | FStar_Extraction_ML_Syntax.MLM_Ty
          ((uu____2463,name,_mangled_name,uu____2466,uu____2467)::uu____2468)
          ->
          (FStar_Util.print1
             "Warning: not translating definition for %s (and possibly others)\n"
             name;
           None)
      | FStar_Extraction_ML_Syntax.MLM_Ty [] ->
          (FStar_Util.print_string
             "Impossible!! Empty block of mutually recursive type declarations";
           None)
      | FStar_Extraction_ML_Syntax.MLM_Top uu____2490 ->
          failwith "todo: translate_decl [MLM_Top]"
      | FStar_Extraction_ML_Syntax.MLM_Exn uu____2492 ->
          failwith "todo: translate_decl [MLM_Exn]"

and translate_type : env -> FStar_Extraction_ML_Syntax.mlty -> typ =
  fun env  ->
    fun t  ->
      match t with
      | FStar_Extraction_ML_Syntax.MLTY_Tuple []
        |FStar_Extraction_ML_Syntax.MLTY_Top  -> TUnit
      | FStar_Extraction_ML_Syntax.MLTY_Var (name,uu____2500) ->
          TBound (find_t env name)
      | FStar_Extraction_ML_Syntax.MLTY_Fun (t1,uu____2502,t2) ->
          TArrow
            (let _0_364 = translate_type env t1  in
             let _0_363 = translate_type env t2  in (_0_364, _0_363))
      | FStar_Extraction_ML_Syntax.MLTY_Named ([],p) when
          let _0_365 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_365 = "Prims.unit" -> TUnit
      | FStar_Extraction_ML_Syntax.MLTY_Named ([],p) when
          let _0_366 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_366 = "Prims.bool" -> TBool
      | FStar_Extraction_ML_Syntax.MLTY_Named ([],("FStar"::m::[],"t")) when
          is_machine_int m -> TInt (FStar_Util.must (mk_width m))
      | FStar_Extraction_ML_Syntax.MLTY_Named ([],("FStar"::m::[],"t'")) when
          is_machine_int m -> TInt (FStar_Util.must (mk_width m))
      | FStar_Extraction_ML_Syntax.MLTY_Named (arg::[],p) when
          let _0_367 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_367 = "FStar.Buffer.buffer" -> TBuf (translate_type env arg)
      | FStar_Extraction_ML_Syntax.MLTY_Named (uu____2523::[],p) when
          let _0_368 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_368 = "FStar.Ghost.erased" -> TAny
      | FStar_Extraction_ML_Syntax.MLTY_Named ([],(path,type_name)) ->
          TQualified (path, type_name)
      | FStar_Extraction_ML_Syntax.MLTY_Named (args,("Prims"::[],t)) when
          FStar_Util.starts_with t "tuple" ->
          TTuple (FStar_List.map (translate_type env) args)
      | FStar_Extraction_ML_Syntax.MLTY_Named (args,lid) ->
          if (FStar_List.length args) > (Prims.parse_int "0")
          then
            TApp
              (let _0_369 = FStar_List.map (translate_type env) args  in
               (lid, _0_369))
          else TQualified lid
      | FStar_Extraction_ML_Syntax.MLTY_Tuple ts ->
          TTuple (FStar_List.map (translate_type env) ts)

and translate_binders :
  env ->
    (FStar_Extraction_ML_Syntax.mlident * FStar_Extraction_ML_Syntax.mlty)
      Prims.list -> binder Prims.list
  = fun env  -> fun args  -> FStar_List.map (translate_binder env) args

and translate_binder :
  env ->
    (FStar_Extraction_ML_Syntax.mlident * FStar_Extraction_ML_Syntax.mlty) ->
      binder
  =
  fun env  ->
    fun uu____2562  ->
      match uu____2562 with
      | ((name,uu____2566),typ) ->
          let _0_370 = translate_type env typ  in
          { name; typ = _0_370; mut = false }

and translate_expr : env -> FStar_Extraction_ML_Syntax.mlexpr -> expr =
  fun env  ->
    fun e  ->
      match e.FStar_Extraction_ML_Syntax.expr with
      | FStar_Extraction_ML_Syntax.MLE_Tuple [] -> EUnit
      | FStar_Extraction_ML_Syntax.MLE_Const c -> translate_constant c
      | FStar_Extraction_ML_Syntax.MLE_Var (name,uu____2574) ->
          EBound (find env name)
      | FStar_Extraction_ML_Syntax.MLE_Name ("FStar"::m::[],op) when
          (is_machine_int m) && (is_op op) ->
          EOp
            (let _0_372 = FStar_Util.must (mk_op op)  in
             let _0_371 = FStar_Util.must (mk_width m)  in (_0_372, _0_371))
      | FStar_Extraction_ML_Syntax.MLE_Name ("Prims"::[],op) when
          is_bool_op op ->
          EOp
            (let _0_373 = FStar_Util.must (mk_bool_op op)  in (_0_373, Bool))
      | FStar_Extraction_ML_Syntax.MLE_Name n -> EQualified n
      | FStar_Extraction_ML_Syntax.MLE_Let
          ((flavor,flags,{
                           FStar_Extraction_ML_Syntax.mllb_name =
                             (name,uu____2584);
                           FStar_Extraction_ML_Syntax.mllb_tysc = Some
                             ([],typ);
                           FStar_Extraction_ML_Syntax.mllb_add_unit =
                             add_unit;
                           FStar_Extraction_ML_Syntax.mllb_def = body;
                           FStar_Extraction_ML_Syntax.print_typ = print;_}::[]),continuation)
          ->
          let is_mut =
            FStar_Util.for_some
              (fun uu___120_2600  ->
                 match uu___120_2600 with
                 | FStar_Extraction_ML_Syntax.Mutable  -> true
                 | uu____2601 -> false) flags
             in
          let uu____2602 =
            if is_mut
            then
              let _0_377 =
                match typ with
                | FStar_Extraction_ML_Syntax.MLTY_Named (t::[],p) when
                    let _0_374 =
                      FStar_Extraction_ML_Syntax.string_of_mlpath p  in
                    _0_374 = "FStar.ST.stackref" -> t
                | uu____2610 ->
                    failwith
                      (let _0_375 =
                         FStar_Extraction_ML_Code.string_of_mlty ([], "") typ
                          in
                       FStar_Util.format1
                         "unexpected: bad desugaring of Mutable (typ is %s)"
                         _0_375)
                 in
              let _0_376 =
                match body with
                | {
                    FStar_Extraction_ML_Syntax.expr =
                      FStar_Extraction_ML_Syntax.MLE_App
                      (uu____2612,body::[]);
                    FStar_Extraction_ML_Syntax.mlty = uu____2614;
                    FStar_Extraction_ML_Syntax.loc = uu____2615;_} -> body
                | uu____2617 ->
                    failwith "unexpected: bad desugaring of Mutable"
                 in
              (_0_377, _0_376)
            else (typ, body)  in
          (match uu____2602 with
           | (typ,body) ->
               let binder =
                 let _0_378 = translate_type env typ  in
                 { name; typ = _0_378; mut = is_mut }  in
               let body = translate_expr env body  in
               let env = extend env name is_mut  in
               let continuation = translate_expr env continuation  in
               ELet (binder, body, continuation))
      | FStar_Extraction_ML_Syntax.MLE_Match (expr,branches) ->
          EMatch
            (let _0_380 = translate_expr env expr  in
             let _0_379 = translate_branches env branches  in
             (_0_380, _0_379))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2641;
             FStar_Extraction_ML_Syntax.loc = uu____2642;_},{
                                                              FStar_Extraction_ML_Syntax.expr
                                                                =
                                                                FStar_Extraction_ML_Syntax.MLE_Var
                                                                (v,uu____2644);
                                                              FStar_Extraction_ML_Syntax.mlty
                                                                = uu____2645;
                                                              FStar_Extraction_ML_Syntax.loc
                                                                = uu____2646;_}::[])
          when
          (let _0_381 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
           _0_381 = "FStar.ST.op_Bang") && (is_mutable env v)
          -> EBound (find env v)
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2649;
             FStar_Extraction_ML_Syntax.loc = uu____2650;_},{
                                                              FStar_Extraction_ML_Syntax.expr
                                                                =
                                                                FStar_Extraction_ML_Syntax.MLE_Var
                                                                (v,uu____2652);
                                                              FStar_Extraction_ML_Syntax.mlty
                                                                = uu____2653;
                                                              FStar_Extraction_ML_Syntax.loc
                                                                = uu____2654;_}::e::[])
          when
          (let _0_382 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
           _0_382 = "FStar.ST.op_Colon_Equals") && (is_mutable env v)
          ->
          EAssign
            (let _0_384 = EBound (find env v)  in
             let _0_383 = translate_expr env e  in (_0_384, _0_383))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2658;
             FStar_Extraction_ML_Syntax.loc = uu____2659;_},e1::e2::[])
          when
          (let _0_385 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
           _0_385 = "FStar.Buffer.index") ||
            (let _0_386 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
             _0_386 = "FStar.Buffer.op_Array_Access")
          ->
          EBufRead
            (let _0_388 = translate_expr env e1  in
             let _0_387 = translate_expr env e2  in (_0_388, _0_387))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2664;
             FStar_Extraction_ML_Syntax.loc = uu____2665;_},e1::e2::[])
          when
          let _0_389 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_389 = "FStar.Buffer.create" ->
          EBufCreate
            (let _0_391 = translate_expr env e1  in
             let _0_390 = translate_expr env e2  in (Stack, _0_391, _0_390))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2670;
             FStar_Extraction_ML_Syntax.loc = uu____2671;_},_e0::e1::e2::[])
          when
          let _0_392 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_392 = "FStar.Buffer.rcreate" ->
          EBufCreate
            (let _0_394 = translate_expr env e1  in
             let _0_393 = translate_expr env e2  in (Eternal, _0_394, _0_393))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2677;
             FStar_Extraction_ML_Syntax.loc = uu____2678;_},e2::[])
          when
          let _0_395 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_395 = "FStar.Buffer.createL" ->
          let rec list_elements acc e2 =
            match e2.FStar_Extraction_ML_Syntax.expr with
            | FStar_Extraction_ML_Syntax.MLE_CTor
                (("Prims"::[],"Cons"),hd::tl::[]) ->
                list_elements (hd :: acc) tl
            | FStar_Extraction_ML_Syntax.MLE_CTor (("Prims"::[],"Nil"),[]) ->
                FStar_List.rev acc
            | uu____2704 ->
                failwith
                  "Argument of FStar.Buffer.createL is not a string literal!"
             in
          let list_elements = list_elements []  in
          EBufCreateL
            (let _0_397 =
               let _0_396 = list_elements e2  in
               FStar_List.map (translate_expr env) _0_396  in
             (Stack, _0_397))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2712;
             FStar_Extraction_ML_Syntax.loc = uu____2713;_},e1::e2::_e3::[])
          when
          let _0_398 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_398 = "FStar.Buffer.sub" ->
          EBufSub
            (let _0_400 = translate_expr env e1  in
             let _0_399 = translate_expr env e2  in (_0_400, _0_399))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2719;
             FStar_Extraction_ML_Syntax.loc = uu____2720;_},e1::e2::[])
          when
          let _0_401 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_401 = "FStar.Buffer.join" -> translate_expr env e1
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2725;
             FStar_Extraction_ML_Syntax.loc = uu____2726;_},e1::e2::[])
          when
          let _0_402 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_402 = "FStar.Buffer.offset" ->
          EBufSub
            (let _0_404 = translate_expr env e1  in
             let _0_403 = translate_expr env e2  in (_0_404, _0_403))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2731;
             FStar_Extraction_ML_Syntax.loc = uu____2732;_},e1::e2::e3::[])
          when
          (let _0_405 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
           _0_405 = "FStar.Buffer.upd") ||
            (let _0_406 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
             _0_406 = "FStar.Buffer.op_Array_Assignment")
          ->
          EBufWrite
            (let _0_409 = translate_expr env e1  in
             let _0_408 = translate_expr env e2  in
             let _0_407 = translate_expr env e3  in (_0_409, _0_408, _0_407))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2738;
             FStar_Extraction_ML_Syntax.loc = uu____2739;_},uu____2740::[])
          when
          let _0_410 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_410 = "FStar.ST.push_frame" -> EPushFrame
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2743;
             FStar_Extraction_ML_Syntax.loc = uu____2744;_},uu____2745::[])
          when
          let _0_411 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_411 = "FStar.ST.pop_frame" -> EPopFrame
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2748;
             FStar_Extraction_ML_Syntax.loc = uu____2749;_},e1::e2::e3::e4::e5::[])
          when
          let _0_412 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_412 = "FStar.Buffer.blit" ->
          EBufBlit
            (let _0_417 = translate_expr env e1  in
             let _0_416 = translate_expr env e2  in
             let _0_415 = translate_expr env e3  in
             let _0_414 = translate_expr env e4  in
             let _0_413 = translate_expr env e5  in
             (_0_417, _0_416, _0_415, _0_414, _0_413))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2757;
             FStar_Extraction_ML_Syntax.loc = uu____2758;_},e1::e2::e3::[])
          when
          let _0_418 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_418 = "FStar.Buffer.fill" ->
          EBufFill
            (let _0_421 = translate_expr env e1  in
             let _0_420 = translate_expr env e2  in
             let _0_419 = translate_expr env e3  in (_0_421, _0_420, _0_419))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2764;
             FStar_Extraction_ML_Syntax.loc = uu____2765;_},uu____2766::[])
          when
          let _0_422 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_422 = "FStar.ST.get" -> EUnit
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name p;
             FStar_Extraction_ML_Syntax.mlty = uu____2769;
             FStar_Extraction_ML_Syntax.loc = uu____2770;_},e::[])
          when
          let _0_423 = FStar_Extraction_ML_Syntax.string_of_mlpath p  in
          _0_423 = "Obj.repr" ->
          ECast (let _0_424 = translate_expr env e  in (_0_424, TAny))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name ("FStar"::m::[],op);
             FStar_Extraction_ML_Syntax.mlty = uu____2775;
             FStar_Extraction_ML_Syntax.loc = uu____2776;_},args)
          when (is_machine_int m) && (is_op op) ->
          let _0_426 = FStar_Util.must (mk_width m)  in
          let _0_425 = FStar_Util.must (mk_op op)  in
          mk_op_app env _0_426 _0_425 args
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name ("Prims"::[],op);
             FStar_Extraction_ML_Syntax.mlty = uu____2782;
             FStar_Extraction_ML_Syntax.loc = uu____2783;_},args)
          when is_bool_op op ->
          let _0_427 = FStar_Util.must (mk_bool_op op)  in
          mk_op_app env Bool _0_427 args
      | FStar_Extraction_ML_Syntax.MLE_App
        ({
           FStar_Extraction_ML_Syntax.expr =
             FStar_Extraction_ML_Syntax.MLE_Name ("FStar"::m::[],"int_to_t");
           FStar_Extraction_ML_Syntax.mlty = _;
           FStar_Extraction_ML_Syntax.loc = _;_},{
                                                   FStar_Extraction_ML_Syntax.expr
                                                     =
                                                     FStar_Extraction_ML_Syntax.MLE_Const
                                                     (FStar_Extraction_ML_Syntax.MLC_Int
                                                     (c,None ));
                                                   FStar_Extraction_ML_Syntax.mlty
                                                     = _;
                                                   FStar_Extraction_ML_Syntax.loc
                                                     = _;_}::[])
        |FStar_Extraction_ML_Syntax.MLE_App
        ({
           FStar_Extraction_ML_Syntax.expr =
             FStar_Extraction_ML_Syntax.MLE_Name ("FStar"::m::[],"uint_to_t");
           FStar_Extraction_ML_Syntax.mlty = _;
           FStar_Extraction_ML_Syntax.loc = _;_},{
                                                   FStar_Extraction_ML_Syntax.expr
                                                     =
                                                     FStar_Extraction_ML_Syntax.MLE_Const
                                                     (FStar_Extraction_ML_Syntax.MLC_Int
                                                     (c,None ));
                                                   FStar_Extraction_ML_Syntax.mlty
                                                     = _;
                                                   FStar_Extraction_ML_Syntax.loc
                                                     = _;_}::[])
          when is_machine_int m ->
          EConstant
            (let _0_428 = FStar_Util.must (mk_width m)  in (_0_428, c))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name
               ("C"::[],"string_of_literal");
             FStar_Extraction_ML_Syntax.mlty = uu____2812;
             FStar_Extraction_ML_Syntax.loc = uu____2813;_},{
                                                              FStar_Extraction_ML_Syntax.expr
                                                                = e;
                                                              FStar_Extraction_ML_Syntax.mlty
                                                                = uu____2815;
                                                              FStar_Extraction_ML_Syntax.loc
                                                                = uu____2816;_}::[])
          ->
          (match e with
           | FStar_Extraction_ML_Syntax.MLE_Const
               (FStar_Extraction_ML_Syntax.MLC_String s) -> EString s
           | uu____2820 ->
               failwith
                 "Cannot extract string_of_literal applied to a non-literal")
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name
               ("FStar"::"Int"::"Cast"::[],c);
             FStar_Extraction_ML_Syntax.mlty = uu____2822;
             FStar_Extraction_ML_Syntax.loc = uu____2823;_},arg::[])
          ->
          let is_known_type =
            (((((((FStar_Util.starts_with c "uint8") ||
                    (FStar_Util.starts_with c "uint16"))
                   || (FStar_Util.starts_with c "uint32"))
                  || (FStar_Util.starts_with c "uint64"))
                 || (FStar_Util.starts_with c "int8"))
                || (FStar_Util.starts_with c "int16"))
               || (FStar_Util.starts_with c "int32"))
              || (FStar_Util.starts_with c "int64")
             in
          if (FStar_Util.ends_with c "uint64") && is_known_type
          then
            ECast
              (let _0_429 = translate_expr env arg  in
               (_0_429, (TInt UInt64)))
          else
            if (FStar_Util.ends_with c "uint32") && is_known_type
            then
              ECast
                ((let _0_430 = translate_expr env arg  in
                  (_0_430, (TInt UInt32))))
            else
              if (FStar_Util.ends_with c "uint16") && is_known_type
              then
                ECast
                  ((let _0_431 = translate_expr env arg  in
                    (_0_431, (TInt UInt16))))
              else
                if (FStar_Util.ends_with c "uint8") && is_known_type
                then
                  ECast
                    ((let _0_432 = translate_expr env arg  in
                      (_0_432, (TInt UInt8))))
                else
                  if (FStar_Util.ends_with c "int64") && is_known_type
                  then
                    ECast
                      ((let _0_433 = translate_expr env arg  in
                        (_0_433, (TInt Int64))))
                  else
                    if (FStar_Util.ends_with c "int32") && is_known_type
                    then
                      ECast
                        ((let _0_434 = translate_expr env arg  in
                          (_0_434, (TInt Int32))))
                    else
                      if (FStar_Util.ends_with c "int16") && is_known_type
                      then
                        ECast
                          ((let _0_435 = translate_expr env arg  in
                            (_0_435, (TInt Int16))))
                      else
                        if (FStar_Util.ends_with c "int8") && is_known_type
                        then
                          ECast
                            ((let _0_436 = translate_expr env arg  in
                              (_0_436, (TInt Int8))))
                        else
                          EApp
                            ((let _0_438 =
                                let _0_437 = translate_expr env arg  in
                                [_0_437]  in
                              ((EQualified (["FStar"; "Int"; "Cast"], c)),
                                _0_438)))
      | FStar_Extraction_ML_Syntax.MLE_App
          ({
             FStar_Extraction_ML_Syntax.expr =
               FStar_Extraction_ML_Syntax.MLE_Name (path,function_name);
             FStar_Extraction_ML_Syntax.mlty = uu____2840;
             FStar_Extraction_ML_Syntax.loc = uu____2841;_},args)
          ->
          EApp
            (let _0_439 = FStar_List.map (translate_expr env) args  in
             ((EQualified (path, function_name)), _0_439))
      | FStar_Extraction_ML_Syntax.MLE_Coerce (e,t_from,t_to) ->
          ECast
            (let _0_441 = translate_expr env e  in
             let _0_440 = translate_type env t_to  in (_0_441, _0_440))
      | FStar_Extraction_ML_Syntax.MLE_Record (uu____2852,fields) ->
          EFlat
            (let _0_444 = assert_lid env e.FStar_Extraction_ML_Syntax.mlty
                in
             let _0_443 =
               FStar_List.map
                 (fun uu____2869  ->
                    match uu____2869 with
                    | (field,expr) ->
                        let _0_442 = translate_expr env expr  in
                        (field, _0_442)) fields
                in
             (_0_444, _0_443))
      | FStar_Extraction_ML_Syntax.MLE_Proj (e,path) ->
          EField
            (let _0_446 = assert_lid env e.FStar_Extraction_ML_Syntax.mlty
                in
             let _0_445 = translate_expr env e  in
             (_0_446, _0_445, (Prims.snd path)))
      | FStar_Extraction_ML_Syntax.MLE_Let uu____2879 ->
          failwith "todo: translate_expr [MLE_Let]"
      | FStar_Extraction_ML_Syntax.MLE_App (head,uu____2887) ->
          failwith
            (let _0_447 =
               FStar_Extraction_ML_Code.string_of_mlexpr ([], "") head  in
             FStar_Util.format1
               "todo: translate_expr [MLE_App] (head is: %s)" _0_447)
      | FStar_Extraction_ML_Syntax.MLE_Seq seqs ->
          ESequence (FStar_List.map (translate_expr env) seqs)
      | FStar_Extraction_ML_Syntax.MLE_Tuple es ->
          ETuple (FStar_List.map (translate_expr env) es)
      | FStar_Extraction_ML_Syntax.MLE_CTor ((uu____2895,cons),es) ->
          ECons
            (let _0_449 = assert_lid env e.FStar_Extraction_ML_Syntax.mlty
                in
             let _0_448 = FStar_List.map (translate_expr env) es  in
             (_0_449, cons, _0_448))
      | FStar_Extraction_ML_Syntax.MLE_Fun (args,body) ->
          let binders = translate_binders env args  in
          let env = add_binders env args  in
          EFun (let _0_450 = translate_expr env body  in (binders, _0_450))
      | FStar_Extraction_ML_Syntax.MLE_If (e1,e2,e3) ->
          EIfThenElse
            (let _0_453 = translate_expr env e1  in
             let _0_452 = translate_expr env e2  in
             let _0_451 =
               match e3 with
               | None  -> EUnit
               | Some e3 -> translate_expr env e3  in
             (_0_453, _0_452, _0_451))
      | FStar_Extraction_ML_Syntax.MLE_Raise uu____2924 ->
          failwith "todo: translate_expr [MLE_Raise]"
      | FStar_Extraction_ML_Syntax.MLE_Try uu____2928 ->
          failwith "todo: translate_expr [MLE_Try]"
      | FStar_Extraction_ML_Syntax.MLE_Coerce uu____2936 ->
          failwith "todo: translate_expr [MLE_Coerce]"

and assert_lid : env -> FStar_Extraction_ML_Syntax.mlty -> typ =
  fun env  ->
    fun t  ->
      match t with
      | FStar_Extraction_ML_Syntax.MLTY_Named (ts,lid) ->
          if (FStar_List.length ts) > (Prims.parse_int "0")
          then
            TApp
              (let _0_454 = FStar_List.map (translate_type env) ts  in
               (lid, _0_454))
          else TQualified lid
      | uu____2951 -> failwith "invalid argument: assert_lid"

and translate_branches :
  env ->
    (FStar_Extraction_ML_Syntax.mlpattern * FStar_Extraction_ML_Syntax.mlexpr
      Prims.option * FStar_Extraction_ML_Syntax.mlexpr) Prims.list ->
      (pattern * expr) Prims.list
  =
  fun env  -> fun branches  -> FStar_List.map (translate_branch env) branches

and translate_branch :
  env ->
    (FStar_Extraction_ML_Syntax.mlpattern * FStar_Extraction_ML_Syntax.mlexpr
      Prims.option * FStar_Extraction_ML_Syntax.mlexpr) -> (pattern * expr)
  =
  fun env  ->
    fun uu____2966  ->
      match uu____2966 with
      | (pat,guard,expr) ->
          if guard = None
          then
            let uu____2981 = translate_pat env pat  in
            (match uu____2981 with
             | (env,pat) ->
                 let _0_455 = translate_expr env expr  in (pat, _0_455))
          else failwith "todo: translate_branch"

and translate_pat :
  env -> FStar_Extraction_ML_Syntax.mlpattern -> (env * pattern) =
  fun env  ->
    fun p  ->
      match p with
      | FStar_Extraction_ML_Syntax.MLP_Const
          (FStar_Extraction_ML_Syntax.MLC_Unit ) -> (env, PUnit)
      | FStar_Extraction_ML_Syntax.MLP_Const
          (FStar_Extraction_ML_Syntax.MLC_Bool b) -> (env, (PBool b))
      | FStar_Extraction_ML_Syntax.MLP_Var (name,uu____2997) ->
          let env = extend env name false  in
          (env, (PVar { name; typ = TAny; mut = false }))
      | FStar_Extraction_ML_Syntax.MLP_Wild  ->
          let env = extend env "_" false  in
          (env, (PVar { name = "_"; typ = TAny; mut = false }))
      | FStar_Extraction_ML_Syntax.MLP_CTor ((uu____3000,cons),ps) ->
          let uu____3010 =
            FStar_List.fold_left
              (fun uu____3017  ->
                 fun p  ->
                   match uu____3017 with
                   | (env,acc) ->
                       let uu____3029 = translate_pat env p  in
                       (match uu____3029 with | (env,p) -> (env, (p :: acc))))
              (env, []) ps
             in
          (match uu____3010 with
           | (env,ps) -> (env, (PCons (cons, (FStar_List.rev ps)))))
      | FStar_Extraction_ML_Syntax.MLP_Record (uu____3046,ps) ->
          let uu____3056 =
            FStar_List.fold_left
              (fun uu____3069  ->
                 fun uu____3070  ->
                   match (uu____3069, uu____3070) with
                   | ((env,acc),(field,p)) ->
                       let uu____3107 = translate_pat env p  in
                       (match uu____3107 with
                        | (env,p) -> (env, ((field, p) :: acc)))) (env, [])
              ps
             in
          (match uu____3056 with
           | (env,ps) -> (env, (PRecord (FStar_List.rev ps))))
      | FStar_Extraction_ML_Syntax.MLP_Tuple ps ->
          let uu____3141 =
            FStar_List.fold_left
              (fun uu____3148  ->
                 fun p  ->
                   match uu____3148 with
                   | (env,acc) ->
                       let uu____3160 = translate_pat env p  in
                       (match uu____3160 with | (env,p) -> (env, (p :: acc))))
              (env, []) ps
             in
          (match uu____3141 with
           | (env,ps) -> (env, (PTuple (FStar_List.rev ps))))
      | FStar_Extraction_ML_Syntax.MLP_Const uu____3176 ->
          failwith "todo: translate_pat [MLP_Const]"
      | FStar_Extraction_ML_Syntax.MLP_Branch uu____3179 ->
          failwith "todo: translate_pat [MLP_Branch]"

and translate_constant : FStar_Extraction_ML_Syntax.mlconstant -> expr =
  fun c  ->
    match c with
    | FStar_Extraction_ML_Syntax.MLC_Unit  -> EUnit
    | FStar_Extraction_ML_Syntax.MLC_Bool b -> EBool b
    | FStar_Extraction_ML_Syntax.MLC_Int (s,Some uu____3186) ->
        failwith
          "impossible: machine integer not desugared to a function call"
    | FStar_Extraction_ML_Syntax.MLC_Float uu____3194 ->
        failwith "todo: translate_expr [MLC_Float]"
    | FStar_Extraction_ML_Syntax.MLC_Char uu____3195 ->
        failwith "todo: translate_expr [MLC_Char]"
    | FStar_Extraction_ML_Syntax.MLC_String uu____3196 ->
        failwith "todo: translate_expr [MLC_String]"
    | FStar_Extraction_ML_Syntax.MLC_Bytes uu____3197 ->
        failwith "todo: translate_expr [MLC_Bytes]"
    | FStar_Extraction_ML_Syntax.MLC_Int (uu____3199,None ) ->
        failwith "todo: translate_expr [MLC_Int]"

and mk_op_app :
  env -> width -> op -> FStar_Extraction_ML_Syntax.mlexpr Prims.list -> expr
  =
  fun env  ->
    fun w  ->
      fun op  ->
        fun args  ->
          EApp
            (let _0_456 = FStar_List.map (translate_expr env) args  in
             ((EOp (op, w)), _0_456))
