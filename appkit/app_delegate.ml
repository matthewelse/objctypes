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

  val will_finish_launching : t -> unit
  val did_finish_launching : t -> unit
  val did_become_active : t -> unit
  val will_become_active : t -> unit
  val will_resign_active : t -> unit
  val did_resign_active : t -> unit
  val will_terminate : t -> unit
  val should_terminate_after_last_window_closed : t -> bool
  val should_terminate : t -> Terminate_behaviour.t
end

module Default (T : T) : S with type t = T.t = struct
  include T

  let will_finish_launching _ = ()
  let did_finish_launching _ = ()
  let will_become_active _ = ()
  let did_become_active _ = ()
  let will_resign_active _ = ()
  let did_resign_active _ = ()
  let will_terminate _ = ()
  let should_terminate_after_last_window_closed _ = true
  let should_terminate _ = Terminate_behaviour.Now
end

module Debug (T : S) : S with type t = T.t = struct
  include T

  let will_finish_launching t =
    print_endline "will_finish_launching";
    will_finish_launching t
  ;;

  let did_finish_launching t =
    print_endline "did_finish_launching";
    did_finish_launching t
  ;;

  let will_become_active t =
    print_endline "will_become_active";
    will_become_active t
  ;;

  let did_become_active t =
    print_endline "did_become_active";
    did_become_active t
  ;;

  let will_resign_active t =
    print_endline "will_resign_active";
    will_resign_active t
  ;;

  let did_resign_active t =
    print_endline "did_resign_active";
    did_resign_active t
  ;;

  let will_terminate t =
    print_endline "will_terminate";
    will_terminate t
  ;;

  let should_terminate_after_last_window_closed t =
    print_endline "should_terminate_after_last_window_closed";
    should_terminate_after_last_window_closed t
  ;;

  let should_terminate t =
    print_endline "should_terminate";
    should_terminate t
  ;;
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
    (Selector.register_selector "applicationWillFinishLaunching:")
    ~f:(fun _ _ -> Delegate.will_finish_launching delegate)
    Ctypes.(returning void);
  Class.add_method_exn
    clazz
    (Selector.register_selector "applicationDidFinishLaunching:")
    ~f:(fun _ _ -> Delegate.did_finish_launching delegate)
    Ctypes.(returning void);
  Class.add_method_exn
    clazz
    (Selector.register_selector "applicationWillBecomeActive:")
    ~f:(fun _ _ -> Delegate.will_become_active delegate)
    Ctypes.(returning void);
  Class.add_method_exn
    clazz
    (Selector.register_selector "applicationDidBecomeActive:")
    ~f:(fun _ _ -> Delegate.did_become_active delegate)
    Ctypes.(returning void);
  Class.add_method_exn
    clazz
    (Selector.register_selector "applicationWillResignActive:")
    ~f:(fun _ _ -> Delegate.will_resign_active delegate)
    Ctypes.(returning void);
  Class.add_method_exn
    clazz
    (Selector.register_selector "applicationDidResignActive:")
    ~f:(fun _ _ -> Delegate.did_resign_active delegate)
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
