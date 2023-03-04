open! Core
open! Import

type t = Bindings.Types.Object.t structure ptr

let typ = Bindings.Types.Object.typ

let msg_send t selector selector_typ =
  let f =
    coerce
      (ptr void)
      (Foreign.funptr (ptr typ @-> ptr Selector.typ @-> selector_typ))
      Bindings.Functions.objc_msgSend
  in
  f t selector
;;

let class_ t =
  let selector = Selector.register_selector "class" in
  let selector_typ = returning (ptr Class.typ) in
  msg_send t selector selector_typ
;;

let sexp_of_t t =
  let name = Class.name (class_ t) in
  let raw_ptr =
    if Ppx_inline_test_lib.Runtime.am_running_inline_test
       (* urgh the thing above doesn't work in dune??? *)
       || Sys.getenv "INSIDE_DUNE" |> Option.is_some
    then "<ptr hidden in tests>"
    else
      Nativeint.Hex.to_string
        (Ctypes.raw_address_of_ptr (Ctypes.coerce (ptr typ) (ptr void) t))
  in
  [%message name raw_ptr]
;;
