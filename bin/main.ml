open! Core
open! Objctypes
open! Objctypes_foundation

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
  val did_finish_launching : Foundation.nsobject -> unit
end

let register_app_delegate app (module AppDelegate : AppDelegate) =
  let superclass = Objctypes.Class.lookup_exn "NSObject" in
  let clazz = Class.with_superclass superclass "OCMLAppDelegate" |> Option.value_exn in
  let did_register_method =
    Class.add_method
      clazz
      (Selector.register_selector "applicationDidFinishLaunching:")
      ~f:(fun ptr _sel ->
        AppDelegate.did_finish_launching (new Foundation.nsobject (Some ptr)))
      ~type_:"@:v"
  in
  assert did_register_method;
  let delegate =
    Class.msg_send
      clazz
      (Objctypes.Selector.register_selector "new")
      Ctypes.(returning (ptr Object.typ))
  in
  Object.msg_send
    app
    (Objctypes.Selector.register_selector "setDelegate:")
    Ctypes.(ptr Object.typ @-> returning void)
    delegate;
  delegate
;;

let () =
  print_endline "Hello, World!";
  activate_cocoa_multithreading ();
  print_endline "Activated cocoa multithreading";
  let _pool = new Foundation.nsautoreleasepool None in
  let app : Object.t =
    Class.msg_send
      (force register_app_class)
      (Objctypes.Selector.register_selector "sharedApplication")
      Ctypes.(returning (ptr Object.typ))
  in
  let _delegate =
    register_app_delegate
      app
      (module struct
        let did_finish_launching _ = print_endline "did_finish_launching!!!"
      end)
  in
  Object.msg_send app (Selector.register_selector "run") Ctypes.(returning void)
;;
