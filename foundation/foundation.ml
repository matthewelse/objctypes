open! Core
open! Import

let description_sel = Selector.register_selector "description"
let description_typ = Ctypes.(returning (ptr Object.typ))
let cStringUsingEncoding = Selector.register_selector "cStringUsingEncoding:"
let cStringUsingEncoding_typ = Ctypes.(uint @-> returning string_opt)

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

class virtual baseobject =
  object
    val virtual ptr : Object.t
  end

class nsobject (init_ptr : Object.t option) =
  let init_ptr =
    Option.value_or_thunk init_ptr ~default:(fun () ->
        let clazz = Class.lookup_exn "NSObject" in
        let ptr =
          Objctypes.Class.msg_send
            clazz
            (Objctypes.Selector.register_selector "new")
            Ctypes.(returning (ptr Object.typ))
        in
        ptr)
  in
  object
    inherit baseobject
    val ptr = init_ptr

    method description =
      let obj = Object.msg_send ptr description_sel description_typ in
      new nsstring (Some obj)

    method hash =
      let hash = Objctypes.Selector.register_selector "hash" in
      let hash_typ = Ctypes.(returning uint64_t) in
      Object.msg_send ptr hash hash_typ |> Unsigned.UInt64.to_int64
  end

and nsstring init_ptr =
  let init_ptr : Object.t =
    Option.value_or_thunk init_ptr ~default:(fun () ->
        let clazz = Class.lookup_exn "NSObject" in
        let ptr =
          Objctypes.Class.msg_send
            clazz
            (Objctypes.Selector.register_selector "new")
            Ctypes.(returning (ptr Object.typ))
        in
        ptr)
  in
  object
    inherit nsobject (Some init_ptr)

    method to_string encoding =
      Object.msg_send
        ptr
        cStringUsingEncoding
        cStringUsingEncoding_typ
        (Unsigned.UInt.of_int (Encoding.to_int encoding))
  end

class nsthread init_ptr =
  let init_ptr : Object.t =
    Option.value_or_thunk init_ptr ~default:(fun () ->
        let clazz = Class.lookup_exn "NSThread" in
        let ptr =
          Objctypes.Class.msg_send
            clazz
            (Objctypes.Selector.register_selector "new")
            Ctypes.(returning (ptr Object.typ))
        in
        ptr)
  in
  object
    inherit nsobject (Some init_ptr)

    method start =
      Object.msg_send
        ptr
        (Objctypes.Selector.register_selector "start")
        Ctypes.(returning void)
  end

class nsautoreleasepool init_ptr =
  let init_ptr : Object.t =
    Option.value_or_thunk init_ptr ~default:(fun () ->
        let clazz = Class.lookup_exn "NSThread" in
        let ptr =
          Objctypes.Class.msg_send
            clazz
            (Objctypes.Selector.register_selector "new")
            Ctypes.(returning (ptr Object.typ))
        in
        ptr)
  in
  object
    inherit nsobject (Some init_ptr)
  end

class nsarray init_ptr =
  let init_ptr : Object.t =
    Option.value_or_thunk init_ptr ~default:(fun () ->
        let clazz = Class.lookup_exn "NSArray" in
        let ptr =
          Objctypes.Class.msg_send
            clazz
            (Objctypes.Selector.register_selector "new")
            Ctypes.(returning (ptr Object.typ))
        in
        ptr)
  in
  object
    inherit nsobject (Some init_ptr)
  end

let sexp_of_nsarray ns_array =
  Sexp.Atom (ns_array#description#to_string Encoding.Utf8 |> Option.value_exn)
;;
