open! Core
open! Import

type t = Bindings.Types.Class.t structure ptr

let typ = Bindings.Types.Class.typ
let name t = Bindings.Functions.class_getName t

let sexp_of_t t =
  let name = name t in
  let raw_ptr = Ctypes.raw_address_of_ptr (Ctypes.coerce (ptr typ) (ptr void) t) in
  [%message "" ~_:(name : string) ~_:(raw_ptr : Nativeint.Hex.t)]
;;

let lookup name = Bindings.Functions.objc_getClass name

let lookup_exn name =
  lookup name |> Option.value_exn ~message:[%string "Unable to find class %{name}"]
;;

let msg_send t selector selector_typ =
  let f =
    coerce
      (ptr void)
      (Foreign.funptr (ptr typ @-> ptr Selector.typ @-> selector_typ))
      Bindings.Functions.objc_msgSend
  in
  f t selector
;;

let with_superclass super name = Bindings.Functions.objc_allocateClassPair super name 0

let void_class_method =
  ptr Bindings.Types.Object.typ @-> ptr Selector.typ @-> returning void
;;

let bool_class_method =
  ptr Bindings.Types.Object.typ @-> ptr Selector.typ @-> returning bool
;;

module New_method_void = (val Foreign.dynamic_funptr void_class_method)
module New_method_bool = (val Foreign.dynamic_funptr bool_class_method)

let encode_type (type a) (typ : a typ) =
  match typ with
  | Void -> "v"
  | Primitive x ->
    (match x with
    | Char -> "c"
    | Schar | Int8_t -> "c"
    | Uchar | Uint8_t -> "C"
    | Short | Int16_t -> "s"
    | Ushort | Uint16_t -> "S"
    | Sint | Int | Int32_t -> "i"
    | Uint | Uint32_t -> "l"
    | Long -> "l"
    | Llong | Int64_t -> "q"
    | Ulong | Uint64_t | Camlint | Nativeint -> "L"
    | Size_t -> "L"
    | Ullong -> "Q"
    | Float -> "f"
    | Double -> "d"
    | LDouble -> "?"
    | Complex32 -> "{re=fim=f}"
    | Complex64 -> "{re=dim=d}"
    | Complexld -> "{re=?im=?}"
    | Bool -> "B")
  | _ -> assert false
;;

let rec encode_fn : type a. a fn -> string = function
  | Returns typ -> encode_type typ
  | Function (l, r) -> encode_type l ^ encode_fn r
;;

let add_method (type a) t sel (method_typ : a fn) ~f =
  let method_typ_with_obj_and_sel : (_ -> _ -> a) fn =
    ptr Bindings.Types.Object.typ @-> ptr Selector.typ @-> method_typ
  in
  let type_ = "@:" ^ encode_fn method_typ in
  let module Funptr = (val Foreign.dynamic_funptr method_typ_with_obj_and_sel) in
  let add_method_typ =
    ptr typ @-> ptr Selector.typ @-> Funptr.t @-> string @-> returning bool
  in
  let add_method =
    coerce (ptr void) (Foreign.funptr add_method_typ) Bindings.Functions.class_addMethod
  in
  add_method t sel (Funptr.of_fun f) type_
;;

let add_method_exn t sel method_typ ~f =
  if not (add_method t sel method_typ ~f) then failwith "Unable to add method to class."
;;
