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

  val will_finish_launching : t -> unit
  val did_finish_launching : t -> unit
  val did_become_active : t -> unit
  val will_become_active : t -> unit
  val will_resign_active : t -> unit
  val did_resign_active : t -> unit
  val will_terminate : t -> unit
  val should_terminate_after_last_window_closed : t -> bool
  val should_terminate : t -> Terminate_behaviour.t
end

module Default (T : T) : S with type t = T.t
module Debug (T : S) : S with type t = T.t

val register_app_delegate : Object.t -> (module S with type t = 't) -> 't -> Object.t
