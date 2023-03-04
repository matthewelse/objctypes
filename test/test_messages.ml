open! Core
open! Import

let%expect_test "basic example: [NSObject hash]" =
  let _NSObject = Objctypes.Class.lookup_exn "NSObject" in
  let hash = Objctypes.Selector.register_selector "hash" in
  let hash_typ = Ctypes.(returning uint64_t) in
  let hash_res = Objctypes.Class.msg_send _NSObject hash hash_typ in
  let hash_res = Unsigned.UInt64.to_int64 hash_res in
  print_s [%message (hash_res : Int64.t)];
  (* TODO: I'd bet a lot of money that this number isn't stable :) *)
  [%expect {| (hash_res 8822022896) |}]
;;

let%expect_test "basic example: create an NSObject" =
  let _NSObject = Class.lookup_exn "NSObject" in
  let _NSArray = Class.lookup_exn "NSArray" in
  let new_ = Selector.register_selector "new" in
  let new_typ = Ctypes.(returning (ptr Object.typ)) in
  let new_res = Class.msg_send _NSObject new_ new_typ in
  print_s [%message (new_res : Object.t)];
  [%expect {| (new_res (NSObject "<ptr hidden in tests>")) |}];
  let is_kind_sel = Selector.register_selector "isKindOfClass:" in
  let is_kind_typ = Ctypes.(ptr Class.typ @-> returning bool) in
  let is_kind_NSObject = Object.msg_send new_res is_kind_sel is_kind_typ _NSObject in
  print_s [%message (is_kind_NSObject : bool)];
  [%expect {| (is_kind_NSObject true) |}];
  let is_kind_NSArray = Object.msg_send new_res is_kind_sel is_kind_typ _NSArray in
  print_s [%message (is_kind_NSArray : bool)];
  [%expect {| (is_kind_NSArray false) |}];
  let release = Selector.register_selector "release" in
  let release_typ = Ctypes.(returning void) in
  Object.msg_send new_res release release_typ
;;

let%expect_test "foundation: description" =
  let _NSObject = Class.lookup_exn "NSObject" in
  let _NSArray = Class.lookup_exn "NSArray" in
  let new_ = Selector.register_selector "new" in
  let new_typ = Ctypes.(returning (ptr Object.typ)) in
  let new_res = Class.msg_send _NSObject new_ new_typ in
  print_s [%message (new_res : Object.t)];
  [%expect {| (new_res (NSObject "<ptr hidden in tests>")) |}];
  let desc = Objctypes_foundation.NSObject.description new_res in
  let desc = Objctypes_foundation.NSString.to_string desc Utf8 |> Option.value_exn in
  let desc =
    (* hide the actual pointer to make the test deterministic *)
    String.sub desc ~pos:0 ~len:13 ^ "0000000000" ^ String.subo desc ~pos:22
  in
  print_s [%message (desc : string)];
  [%expect {| (desc "<NSObject: 0x0000000000>") |}]
;;
