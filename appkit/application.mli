open! Core
open! Import

type t

val create : (module App_delegate.S with type t = 'delegate) -> 'delegate -> t
val run : t -> unit
