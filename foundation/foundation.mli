open! Core
open! Import

module Encoding : sig
  type t =
    | Ascii
    | NextStepAscii
    | JapaneseEuc
    | Utf8
end

class nsobject :
  Object.t option
  -> object
       val ptr : Object.t
       method description : nsstring
       method hash : Int64.t
       method raw_ptr : Object.t
     end

and nsstring :
  Object.t option
  -> object
       inherit nsobject
       method to_string : Encoding.t -> string option
       method init_from_string : string -> nsstring
     end

class nsthread :
  Object.t option
  -> object
       inherit nsobject
       method start : unit
     end

class nsautoreleasepool :
  Object.t option
  -> object
       inherit nsobject
       method drain : unit
     end

class nsarray :
  Object.t option
  -> object
       inherit nsobject
     end

val sexp_of_nsobject : nsobject -> Sexp.t
val sexp_of_nsautoreleasepool : nsautoreleasepool -> Sexp.t
val nsstring_of_string : string -> nsstring
