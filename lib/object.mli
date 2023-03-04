(** Runtime representation of an Objective-C object at runtime. *)

open! Core
open! Import

type t = Bindings.Types.Object.t structure ptr [@@deriving sexp_of]

val typ : Bindings.Types.Object.t structure typ

(* TODO: make it clear that this function is (very) unsafe! *)
val msg_send : t -> Selector.t -> 'a fn -> 'a
