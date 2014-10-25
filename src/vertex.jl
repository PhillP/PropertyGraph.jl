type Vertex <: Container
	id::UUID.Uuid
	containedobject::Any
	attachedproperties::Dict{String,Any}

	graph::Any
	# incomingedges and outgoingEdgens are declared Set{Container} instead of Sert{Edge}
	# in order to avoid mutually circular type declaration with Edge
	# see: https://github.com/JuliaLang/julia/issues/269
	incomingedges::Set{Container}
	outgoingedges::Set{Container}
	typelabel::String

	function Vertex(properties::Dict{String,Any}=Dict{String,Any}())
		v = new()
		v.id = UUID.v4()

		v.attachedproperties = properties

		v.incomingedges = Set{Container}()
		v.outgoingedges = Set{Container}()

		return v
	end

	function Vertex(typelabel::String, properties::Dict{String,Any})
		v = Vertex(properties)
		v.typelabel = typelabel

		return v
	end

	function Vertex(typelabel::String)
		v = Vertex(typelabel, Dict{String,Any}())

		return v
	end
end

function VertexForObject(object::Any, properties::Dict{String,Any}=Dict{String,Any}())
	v = Vertex(properties)
	v.containedobject = object

	return v
end

function VertexForObject(typelabel::String, object::Any, properties::Dict{String,Any}=Dict{String,Any}())
	v = Vertex(properties)
	v.typelabel = typelabel
	v.containedobject = object

	return v
end
