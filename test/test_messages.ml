open! Core
open! Import

let%expect_test "foundation: description" =
  let obj = new Objctypes_foundation.Foundation.nsarray None in
  print_s [%message (obj : Objctypes_foundation.Foundation.nsarray)];
  [%expect {|
    (obj  "(\
         \n)") |}];
  let desc = obj#description in
  let desc = desc#to_string Utf8 |> Option.value_exn in
  print_s [%message (desc : string)];
  [%expect {|
    (desc  "(\
          \n)") |}]
;;
