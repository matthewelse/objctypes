open Ctypes

module Types (F : TYPE) = struct
  open F

  let objc_class : Objc_types.Class.t structure typ = structure "objc_class"
  let objc_sel : Objc_types.Sel.t structure typ = structure "objc_selector"
  let objc_method : Objc_types.Method.t structure typ = structure "objc_method"
end
