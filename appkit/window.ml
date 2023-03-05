open! Core
open! Import

type t = Object.t

let sexp_of_t t = new Foundation.nsobject (Some t) |> Foundation.sexp_of_nsobject

let alloc () =
  let clazz = Class.lookup_exn "NSWindow" in
  Objctypes.Class.msg_send
    clazz
    (Objctypes.Selector.register_selector "alloc")
    Ctypes.(returning (ptr Object.typ))
;;

let init_with_content_rect ptr ~x ~y ~width ~height =
  Object.msg_send
    ptr
    (Selector.register_selector "initWithContentRect:styleMask:backing:defer:")
    Ctypes.(
      double
      @-> double
      @-> double
      @-> double
      @-> int
      @-> int
      @-> bool
      @-> returning (ptr Object.typ))
    x
    y
    width
    height
    ((1 lsl 3) lor (1 lsl 2) lor (1 lsl 12) lor (1 lsl 1) lor (1 lsl 0) lor (1 lsl 15))
    2
    true
;;

let auto_release ptr =
  Object.msg_send ptr (Selector.register_selector "autorelease") Ctypes.(returning void)
;;

let set_released_when_closed ptr to_ =
  Object.msg_send
    ptr
    (Selector.register_selector "setReleasedWhenClosed:")
    Ctypes.(bool @-> returning void)
    to_
;;

let set_restorable ptr to_ =
  Object.msg_send
    ptr
    (Selector.register_selector "setRestorable:")
    Ctypes.(bool @-> returning void)
    to_
;;

let set_toolbar_style ptr to_ =
  Object.msg_send
    ptr
    (Selector.register_selector "setToolbarStyle:")
    Ctypes.(int @-> returning void)
    to_
;;

let create () =
  let ptr = alloc () in
  let ptr = init_with_content_rect ptr ~width:1024. ~height:768. ~x:100. ~y:100. in
  auto_release ptr;
  set_released_when_closed ptr false;
  set_restorable ptr false;
  set_toolbar_style ptr 0;
  ptr
;;

let set_minimum_content_size ptr ~(width : float) ~(height : float) =
  (* TODO: wrap CGSize rather than passing as two separate args. I think
      this should be ABI compatible though. *)
  Object.msg_send
    ptr
    (Selector.register_selector "setContentMinSize:")
    Ctypes.(double @-> double @-> returning void)
    width
    height
;;

let set_title ptr title =
  Object.msg_send
    ptr
    (Selector.register_selector "setTitle:")
    Ctypes.(ptr Object.typ @-> returning void)
    (Foundation.nsstring_of_string title)#raw_ptr
;;

let show ptr =
  Object.msg_send
    ptr
    (Selector.register_selector "makeKeyAndOrderFront:")
    Ctypes.(ptr void @-> returning void)
    Ctypes.null
;;
