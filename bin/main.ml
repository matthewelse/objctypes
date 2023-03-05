open! Core
open! Objctypes
open! Objctypes_foundation
open! Objctypes_appkit

module App_inner = struct
  module T = struct
    type t = { window : Window.t }
  end

  include T
  include App_delegate.Default (T)

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
    Window.set_minimum_content_size window ~width:300. ~height:300.;
    Window.set_title window "hello from ocaml!";
    Window.show window
  ;;
end

module App = App_delegate.Debug (App_inner)

let () =
  let app = Application.create (module App) { window = Window.create () } in
  Application.run app
;;
