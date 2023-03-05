open! Core
open! Import

type t [@@deriving sexp_of]

val create : unit -> t
val set_minimum_content_size : t -> width:float -> height:float -> unit
val set_title : t -> string -> unit
val show : t -> unit
