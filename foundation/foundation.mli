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
       method description : nsstring
       method hash : Int64.t
     end

and nsstring :
  Object.t option
  -> object
       inherit nsobject
       method to_string : Encoding.t -> string option
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
     end

class nsarray :
  Object.t option
  -> object
       inherit nsobject
     end

val sexp_of_nsarray : nsarray -> Sexp.t
