open Ctypes

module Types (F : TYPE) = struct
  open F

  let objc_class : Opaque_types.Class.t structure typ = structure "objc_class"
  let objc_object : Opaque_types.Object.t structure typ = structure "objc_object"
  let objc_selector : Opaque_types.Selector.t structure typ = structure "objc_selector"
  let objc_method : Opaque_types.Method.t structure typ = structure "objc_method"
end
