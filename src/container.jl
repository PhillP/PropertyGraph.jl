# type that represent an Edge or a Vertex and contains a reference to another object
abstract Container

# Type used to represent Unspecified values
immutable Unspecified end
const UnspecifiedValue = Unspecified()

function setpropertyvalue!(c::Container, propertykey::String, value::Any)
	# set a single property value on the supplied container
	c.attachedproperties[propertykey] = value
end

function setpropertyvalues!(c::Container, properties::Dict{String, Any} )
	# set multiple property values on the supplied container based on a supplied property dictionary
	merge!(c.attachedproperties, properties)
end

function get(c::Container, name::String, default::Any=UnspecifiedValue)
	# get the value of a specified property, returning a default value if there is no other property value associated
	return Base.get(c.attachedproperties,name,default)
end
