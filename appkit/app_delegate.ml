open! Core
open! Import

module Terminate_behaviour = struct
  type t =
    | Now
    | Cancel
    | Later
  [@@deriving sexp_of]

  let to_int = function
    | Now -> 1
    | Cancel -> 0
    | Later -> 2
  ;;

  let _ = Cancel
  let _ = Later
end

module type S = sig
  type t

  val did_finish_launching : t -> unit
  val will_terminate : t -> unit
  val should_terminate_after_last_window_closed : t -> bool
  val should_terminate : t -> Terminate_behaviour.t
end

let register_app_delegate
    (type delegate)
    app
    (module Delegate : S with type t = delegate)
    delegate
  =
  let superclass = Objctypes.Class.lookup_exn "NSObject" in
  let clazz = Class.with_superclass superclass "OCMLAppDelegate" |> Option.value_exn in
  let delegate_obj =
    Class.msg_send
      clazz
      (Objctypes.Selector.register_selector "new")
      Ctypes.(returning (ptr Object.typ))
  in
  Class.add_method_exn
    clazz
    (Selector.register_selector "applicationDidFinishLaunching:")
    ~f:(fun _ _ -> Delegate.did_finish_launching delegate)
    Ctypes.(returning void);
  Class.add_method_exn
    clazz
    (Selector.register_selector "applicationWillTerminate:")
    ~f:(fun _ _ -> Delegate.will_terminate delegate)
    Ctypes.(returning void);
  Class.add_method_exn
    clazz
    (Selector.register_selector "shouldTerminateAfterLastWindowClosed:")
    ~f:(fun _ _ -> Delegate.should_terminate_after_last_window_closed delegate)
    Ctypes.(returning bool);
  Class.add_method_exn
    clazz
    (Selector.register_selector "applicationShouldTerminate:")
    ~f:(fun _ _ -> Delegate.should_terminate delegate |> Terminate_behaviour.to_int)
    Ctypes.(returning int);
  Object.msg_send
    app
    (Objctypes.Selector.register_selector "setDelegate:")
    Ctypes.(ptr Object.typ @-> returning void)
    delegate_obj;
  delegate_obj
;;
