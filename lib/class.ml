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
