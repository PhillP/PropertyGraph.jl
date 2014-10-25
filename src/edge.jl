type Edge <: Container
	id::UUID.Uuid
	containedobject::Any
	attachedproperties::Dict{String,Any}

	graph::Any
	tail::Vertex
	head::Vertex
	typelabel::String


	function Edge(tail::Vertex, head::Vertex, properties::Dict{String,Any})
		e = new()
		e.id = UUID.v4()

		e.tail = tail
		e.head = head

		e.attachedproperties = properties

		return e
	end

	function Edge(tail::Vertex, head::Vertex)
		e = Edge(tail, head, Dict{String, Any}())

		return e
	end


	function Edge(typelabel::String, tail::Vertex, head::Vertex, properties::Dict{String,Any}=Dict{String,Any}())
		e = Edge(tail, head, properties)
		e.typelabel = typelabel

		return e
	end
end

function EdgeForObject(object::Any, tail::Vertex, head::Vertex, properties::Dict{String,Any}=Dict{String,Any}())
	e = Edge(tail, head, properties)
	e.containedobject = object

	return e
end

function EdgeForObject(typelabel::String, object::Any, tail::Vertex, head::Vertex, properties::Dict{String,Any}=Dict{String,Any}())
	e = Edge(typelabel, tail, head, properties)
	e.containedobject = object

	return e
end
