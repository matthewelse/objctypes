open Ctypes
module Types = Types_generated

module Functions (F : FOREIGN) = struct
  open F

  let objc_getClass =
    foreign "objc_getClass" (string @-> returning (ptr_opt Types.objc_class))
  ;;

  let objc_msgSend = foreign_value "objc_msgSend" void

  let class_getInstanceMethod =
    foreign
      "class_getInstanceMethod"
      (ptr Types.objc_class
      @-> ptr Types.objc_selector
      @-> returning (ptr_opt Types.objc_method))
  ;;

  let class_getName = foreign "class_getName" (ptr Types.objc_class @-> returning string)

  let method_getName =
    foreign
      "method_getName"
      (ptr Types.objc_method @-> returning (ptr_opt Types.objc_selector))
  ;;

  let sel_registerName =
    foreign "sel_registerName" (string @-> returning (ptr Types.objc_selector))
  ;;

  let sel_getName = foreign "sel_getName" (ptr Types.objc_selector @-> returning string)
end
