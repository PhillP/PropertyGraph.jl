abstract Container

type Unspecified end
const UnspecifiedValue = Unspecified()

function setpropertyvalue!(c::Container, propertykey::String, value::Any)
	c.attachedproperties[propertykey] = value
end

function setpropertyvalues!(c::Container, properties::Dict{String, Any} )
	merge!(c.attachedproperties, properties)
end

function get(c::Container, name::String, default::Any=UnspecifiedValue)
	return Base.get(c.attachedproperties,name,default)
end
