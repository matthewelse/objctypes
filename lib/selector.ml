open! Core
open! Import

type t = Bindings.Types.Selector.t structure ptr

let typ = Bindings.Types.Selector.typ
let name t = Bindings.Functions.sel_getName t

let sexp_of_t t =
  let name = name t in
  let t = coerce (ptr typ) (ptr void) t in
  let raw_ptr = Ctypes.raw_address_of_ptr t in
  [%message "" ~_:(name : string) ~_:(raw_ptr : Nativeint.Hex.t)]
;;

let register_selector name =
  (* TODO: do something similar to cacao in rust, and cache selectors. *)
  Bindings.Functions.sel_registerName name
;;
