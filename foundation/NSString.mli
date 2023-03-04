open! Core
open! Import

type t = String of Object.t [@@unboxed]

module Encoding : sig
  type t =
    | Ascii
    | NextStepAscii
    | JapaneseEuc
    | Utf8

  val to_int : t -> int
end

(** Returns [None] if the string could not be losslessly converted to the
  encoding specified. *)
val to_string : t -> Encoding.t -> string option
