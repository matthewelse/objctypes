open! Core
open! Import

module Terminate_behaviour : sig
  type t =
    | Now
    | Cancel
    | Later
  [@@deriving sexp_of]
end

module type S = sig
  type t

  val did_finish_launching : t -> unit
  val will_terminate : t -> unit
  val should_terminate_after_last_window_closed : t -> bool
  val should_terminate : t -> Terminate_behaviour.t
end

val register_app_delegate : Object.t -> (module S with type t = 't) -> 't -> Object.t
