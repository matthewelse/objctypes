open! Core
open! Import

type t = String of Object.t [@@unboxed]

module Encoding = struct
  type t =
    | Ascii
    | NextStepAscii
    | JapaneseEuc
    | Utf8

  let to_int = function
    | Ascii -> 1
    | NextStepAscii -> 2
    | JapaneseEuc -> 3
    | Utf8 -> 4
  ;;
end

let cStringUsingEncoding = Selector.register_selector "cStringUsingEncoding:"
let cStringUsingEncoding_typ = Ctypes.(uint @-> returning string_opt)

let to_string (String t) encoding =
  Objctypes.Object.msg_send
    t
    cStringUsingEncoding
    cStringUsingEncoding_typ
    (Unsigned.UInt.of_int (Encoding.to_int encoding))
;;
