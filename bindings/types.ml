module Class = struct
  include Opaque_types.Class

  let typ = C.Type.objc_class
end

module Selector = struct
  include Opaque_types.Selector

  let typ = C.Type.objc_selector
end

module Object = struct
  include Opaque_types.Object

  let typ = C.Type.objc_object
end
