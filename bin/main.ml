open! Core
open! Objctypes
open! Objctypes_foundation

class nswindow init_ptr =
  let init_ptr : Object.t =
    Option.value_or_thunk init_ptr ~default:(fun () ->
        let clazz = Class.lookup_exn "NSWindow" in
        let ptr =
          Objctypes.Class.msg_send
            clazz
            (Objctypes.Selector.register_selector "alloc")
            Ctypes.(returning (ptr Object.typ))
        in
        ptr)
  in
  object
    inherit Foundation.nsobject (Some init_ptr)

    method set_minimum_content_size ~(width : float) ~(height : float) =
      (* TODO: wrap CGSize rather than passing as two separate args. I think
      this should be ABI compatible though. *)
      Object.msg_send
        ptr
        (Selector.register_selector "setContentMinSize:")
        Ctypes.(double @-> double @-> returning void)
        width
        height

    method set_title title =
      Object.msg_send
        ptr
        (Selector.register_selector "setTitle:")
        Ctypes.(ptr Object.typ @-> returning void)
        (Foundation.nsstring_of_string title)#raw_ptr

    method show =
      Object.msg_send
        ptr
        (Selector.register_selector "makeKeyAndOrderFront:")
        Ctypes.(ptr void @-> returning void)
        Ctypes.null

    method init_with_content_rect =
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
        100.
        100.
        1024.
        768.
        ((1 lsl 3) lor (1 lsl 2) lor (1 lsl 12) lor (1 lsl 1) lor (1 lsl 0) lor (1 lsl 15))
        2
        true

    method auto_release =
      Object.msg_send
        ptr
        (Selector.register_selector "autorelease")
        Ctypes.(returning void)

    method set_released_when_closed to_ =
      Object.msg_send
        ptr
        (Selector.register_selector "setReleasedWhenClosed:")
        Ctypes.(bool @-> returning void)
        to_

    method set_restorable to_ =
      Object.msg_send
        ptr
        (Selector.register_selector "setRestorable:")
        Ctypes.(bool @-> returning void)
        to_
  end

let new_window () =
  let window = new nswindow None in
  let window = new nswindow (Some window#init_with_content_rect) in
  window#auto_release;
  window#set_released_when_closed false;
  window#set_restorable false;
  window
;;

let activate_cocoa_multithreading () =
  let thread = new Foundation.nsthread None in
  thread#start
;;

let register_app_class =
  Lazy.from_fun (fun () ->
      let superclass = Objctypes.Class.lookup_exn "NSApplication" in
      Objctypes.Class.with_superclass superclass "OCMLApplication" |> Option.value_exn)
;;

module type AppDelegate = sig
  type t

  val did_finish_launching : t -> unit
  val will_terminate : t -> unit
  val should_terminate_after_last_window_closed : t -> bool
end

let register_app_delegate
    (type delegate)
    app
    (module AppDelegate : AppDelegate with type t = delegate)
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
  let did_register_method =
    Class.add_void_method
      clazz
      (Selector.register_selector "applicationDidFinishLaunching:")
      ~f:(fun _ _ -> AppDelegate.did_finish_launching delegate)
      ~type_:"@:v"
  in
  assert did_register_method;
  let did_register_method =
    Class.add_void_method
      clazz
      (Selector.register_selector "applicationWillTerminate:")
      ~f:(fun _ _ -> AppDelegate.will_terminate delegate)
      ~type_:"@:v"
  in
  assert did_register_method;
  let did_register_method =
    Class.add_bool_method
      clazz
      (Selector.register_selector "shouldTerminateAfterLastWindowClosed:")
      ~f:(fun _ _ -> AppDelegate.should_terminate_after_last_window_closed delegate)
      ~type_:"@:B"
  in
  assert did_register_method;
  Object.msg_send
    app
    (Objctypes.Selector.register_selector "setDelegate:")
    Ctypes.(ptr Object.typ @-> returning void)
    delegate_obj
;;

let shared_application () =
  Class.msg_send
    (force register_app_class)
    (Objctypes.Selector.register_selector "sharedApplication")
    Ctypes.(returning (ptr Object.typ))
;;

module App = struct
  type t = { window : nswindow }

  let did_finish_launching { window } =
    (* FIXME: this is all broken. *)
    Object.msg_send
      (shared_application ())
      (Selector.register_selector "setActivationPolicy:")
      Ctypes.(int @-> returning void)
      0;
    (*
    let app =
      Class.msg_send
        (Class.lookup_exn "NSRunningApplication")
        (Selector.register_selector "currentApplication")
        Ctypes.(returning (ptr Object.typ))
    in
    Object.msg_send
      app
      (Selector.register_selector "activateWithOptions:")
      Ctypes.(int @-> returning void)
      (1 lsl 1); *)
    print_s
      [%message
        "did_finish_launching"
          ~window:((window :> Foundation.nsobject) : Foundation.nsobject)];
    window#set_minimum_content_size ~width:300. ~height:300.;
    window#set_title "hello from ocaml!";
    window#show
  ;;

  let will_terminate { window = _ } = print_endline [%string "will terminate:"]

  let should_terminate_after_last_window_closed _ =
    print_endline "should terminate";
    true
  ;;
end

let () =
  print_endline "Hello, World!";
  activate_cocoa_multithreading ();
  print_endline "Activated cocoa multithreading";
  let _pool = new Foundation.nsautoreleasepool None in
  let app : Object.t = shared_application () in
  register_app_delegate app (module App) { window = new_window () };
  Object.msg_send app (Selector.register_selector "run") Ctypes.(returning void)
;;
