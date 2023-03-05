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

    method raw_ptr = ptr
  end

and nsstring init_ptr =
  let init_ptr : Object.t =
    Option.value_or_thunk init_ptr ~default:(fun () ->
        let clazz = Class.lookup_exn "NSString" in
        let ptr =
          Objctypes.Class.msg_send
            clazz
            (Objctypes.Selector.register_selector "alloc")
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

    method init_from_string s =
      let bytes = String.length s in
      let ptr =
        Object.msg_send
          ptr
          (Selector.register_selector "initWithBytes:length:encoding:")
          Ctypes.(string @-> int @-> int @-> returning (ptr Object.typ))
          s
          bytes
          (Encoding.to_int Ascii)
      in
      new nsstring (Some ptr)
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

    method drain =
      Object.msg_send ptr (Selector.register_selector "drain") Ctypes.(returning void)
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

let sexp_of_nsobject ns_object =
  Sexp.Atom (ns_object#description#to_string Encoding.Utf8 |> Option.value_exn)
;;

let sexp_of_nsautoreleasepool = sexp_of_nsobject

let nsstring_of_string s =
  let obj = new nsstring None in
  obj#init_from_string s
;;
