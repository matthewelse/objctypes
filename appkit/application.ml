open! Core
open! Import

type t =
  { objc : Object.t
  ; objc_delegate : Object.t
  ; pool : Foundation.nsautoreleasepool
  }
[@@deriving sexp_of]

let app_class =
  Lazy.from_fun (fun () ->
      let superclass = Objctypes.Class.lookup_exn "NSApplication" in
      Objctypes.Class.with_superclass superclass "OCMLApplication" |> Option.value_exn)
;;

let activate_cocoa_multithreading () =
  let thread = new Foundation.nsthread None in
  thread#start
;;

let create
    (type delegate)
    (module Delegate : App_delegate.S with type t = delegate)
    (delegate : delegate)
  =
  activate_cocoa_multithreading ();
  let pool = new Foundation.nsautoreleasepool None in
  let objc =
    Class.msg_send
      (force app_class)
      (Objctypes.Selector.register_selector "sharedApplication")
      Ctypes.(returning (ptr Object.typ))
  in
  let objc_delegate =
    App_delegate.register_app_delegate objc (module Delegate) delegate
  in
  { objc; objc_delegate; pool }
;;

let run t =
  let objc =
    Class.msg_send
      (force app_class)
      (Objctypes.Selector.register_selector "sharedApplication")
      Ctypes.(returning (ptr Object.typ))
  in
  Object.msg_send objc (Selector.register_selector "run") Ctypes.(returning void);
  t.pool#drain
;;
