# type that represent an Edge or a Vertex and contains a reference to another object
abstract Container

# Type used to represent Unspecified values
immutable Unspecified end
const UnspecifiedValue = Unspecified()

function setpropertyvalue!(c::Container, propertykey::String, value::Any, withtracking::Bool = true)
	# set a single property value on the supplied container
	c.attachedproperties[propertykey] = value
	if withtracking
		trackchange(c)
	end
end

function setpropertyvalues!(c::Container, properties::Dict{String, Any} , withtracking::Bool = true)
	# set multiple property values on the supplied container based on a supplied property dictionary
	merge!(c.attachedproperties, properties)
	if withtracking
		trackchange(c)
	end
end

function clearproperties!(c::Container , withtracking::Bool = true)
	c.attachedproperties = Dict{String, Any}()
	if withtracking
		trackchange(c)
	end
end

function get(c::Container, name::String, default::Any=UnspecifiedValue)
	# get the value of a specified property, returning a default value if there is no other property value associated
	return Base.get(c.attachedproperties,name,default)
end

function gettracker(c::Container)
	associatedtracker = UnspecifiedValue

	if isdefined(c, :graph)
		associatedtracker = gettracker(c.graph)
	end

	return associatedtracker
end

function trackchange(c::Container)
	associatedtracker = gettracker(c)

	if associatedtracker != UnspecifiedValue
		trackchange!(associatedtracker,c)
	end
end

function trackadd(c::Container)
	associatedtracker = gettracker(c)

	if associatedtracker != UnspecifiedValue
		trackadd!(associatedtracker,c)
	end
end

function trackremove(c::Container)
	associatedtracker = gettracker(c)

	if associatedtracker != UnspecifiedValue
		trackremove!(associatedtracker,c)
	end
end
