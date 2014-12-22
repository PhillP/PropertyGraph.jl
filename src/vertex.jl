type Vertex <: Container
	# Represents a Vertex within a Property Graph

	id::UUID.Uuid
	containedobject::Any
	attachedproperties::Dict{String,Any}

	graph::Any
	# incomingedges and outgoingEdgens are declared Set{Container} instead of Set{Edge}
	# in order to avoid mutually circular type declaration with Edge
	# see: https://github.com/JuliaLang/julia/issues/269
	incomingedges::Set{Container}
	outgoingedges::Set{Container}
	typelabel::String
	partiallyloaded::Bool

	function Vertex(properties::Dict{String,Any}=Dict{String,Any}())
		# Construct a Vertex with a set of initial property values

		v = new()
		v.id = UUID.v4()

		v.attachedproperties = properties
		v.containedobject = UnspecifiedValue
		v.typelabel = "Unspecified"

		v.incomingedges = Set{Container}()
		v.outgoingedges = Set{Container}()

		v.partiallyloaded = false

		return v
	end

	function Vertex(typelabel::String, properties::Dict{String,Any})
		# Construct a Vertex with a typelabel and a set of initial property values

		v = Vertex(properties)
		v.typelabel = typelabel

		return v
	end

	function Vertex(typelabel::String)
		# Construct a Vertex with a typelabel

		v = Vertex(typelabel, Dict{String,Any}())

		return v
	end
end

function vertexforobject(object::Any, properties::Dict{String,Any}=Dict{String,Any}())
	# Construct a Vertex for an existing object, and with a set of initial property values

	v = Vertex(properties)
	v.containedobject = object

	return v
end

function vertexforobject(typelabel::String, object::Any, properties::Dict{String,Any}=Dict{String,Any}())
	# Construct a Vertex with a type label, a reference to an existing object, and a set of initial property values

	v = Vertex(properties)
	v.typelabel = typelabel
	v.containedobject = object

	return v
end
