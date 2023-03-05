(** Runtime representation of an Objective-C object. *)

open! Core
open! Import

type t = Bindings.Types.Class.t structure ptr [@@deriving sexp_of]

val typ : Bindings.Types.Class.t structure typ

(** Returns the class with the name specified, if one exists. *)
val lookup : string -> t option

val lookup_exn : string -> t

(** Send a message to this class, e.g. [NSArray new]. If you want to send a
  message to an instance of a class, see [Object.msg_send].
  
  TODO: make it clear that this function is (very) unsafe! *)
val msg_send : t -> Selector.t -> 'a fn -> 'a

val name : t -> string
val with_superclass : t -> string -> t option

type object_ := Bindings.Types.Object.t Ctypes.structure Ctypes_static.ptr

val add_method
  :  t
  -> Selector.t
  -> f:(object_ -> Selector.t -> unit)
  -> type_:string
  -> bool
