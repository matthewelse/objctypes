open! Core
open! Import
include Object

let description_sel = Selector.register_selector "description"
let description_typ = Ctypes.(returning (ptr typ))

let description t : NSString.t =
  let obj : t = Object.msg_send t description_sel description_typ in
  String obj
;;
