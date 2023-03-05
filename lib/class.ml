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

let add_void_method t sel ~f ~type_ =
  let add_method =
    coerce
      (ptr void)
      (Foreign.funptr
         (ptr typ @-> ptr Selector.typ @-> New_method_void.t @-> string @-> returning bool))
      Bindings.Functions.class_addMethod
  in
  add_method t sel (New_method_void.of_fun f) type_
;;

let add_bool_method t sel ~f ~type_ =
  let add_method =
    coerce
      (ptr void)
      (Foreign.funptr
         (ptr typ @-> ptr Selector.typ @-> New_method_bool.t @-> string @-> returning bool))
      Bindings.Functions.class_addMethod
  in
  add_method t sel (New_method_bool.of_fun f) type_
;;
