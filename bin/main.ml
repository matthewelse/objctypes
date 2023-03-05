open! Core
open! Objctypes
open! Objctypes_foundation
open! Objctypes_appkit

module App = struct
  type t = { window : Window.t }

  let did_finish_launching { window } =
    (* FIXME: this is all broken. *)
    (* Object.msg_send
      (shared_application ())
      (Selector.register_selector "setActivationPolicy:")
      Ctypes.(int @-> returning void)
      0; *)
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
    print_s [%message "did_finish_launching" ~(window : Window.t)];
    Window.set_minimum_content_size window ~width:300. ~height:300.;
    Window.set_title window "hello from ocaml!";
    Window.show window
  ;;

  let will_terminate { window = _ } = print_endline [%string "will terminate:"]

  let should_terminate_after_last_window_closed _ =
    print_endline "should terminate after last window closed";
    true
  ;;

  let should_terminate _ =
    print_endline "should terminate";
    App_delegate.Terminate_behaviour.Now
  ;;
end

let () =
  let app = Application.create (module App) { window = Window.create () } in
  Application.run app
;;
