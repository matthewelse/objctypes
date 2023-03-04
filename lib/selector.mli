(** A [Selector.t] is an (untyped) representation of an Objective-C selector at
  runtime. *)

open! Core
open! Import

type t = Bindings.Types.Selector.t structure ptr [@@deriving sexp_of]

val typ : Bindings.Types.Selector.t structure typ
val register_selector : string -> t
