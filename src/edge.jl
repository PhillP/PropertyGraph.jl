type Edge <: Container
	# Represents the edge between 2 vertices

	id::UUID.Uuid
	containedobject::Any
	attachedproperties::Dict{String,Any}

	graph::Any
	tail::Vertex
	head::Vertex
	typelabel::String

	partiallyloaded::Bool

	function Edge(tail::Vertex, head::Vertex, properties::Dict{String,Any})
		# Construct an edge from a pair of vertices with a set of property values

		e = new()
		e.id = UUID.v4()
		e.containedobject = UnspecifiedValue
		e.typelabel = "Unspecified"
		e.tail = tail
		e.head = head

		e.partiallyloaded = false

		e.attachedproperties = properties

		return e
	end

	function Edge(tail::Vertex, head::Vertex)
		# Construct an edge from a pair of vertices

		e = Edge(tail, head, Dict{String, Any}())

		return e
	end


	function Edge(typelabel::String, tail::Vertex, head::Vertex, properties::Dict{String,Any}=Dict{String,Any}())
		# Construct an edge from a typelabel, a pair of vertices, and a set of property values

		e = Edge(tail, head, properties)
		e.typelabel = typelabel

		return e
	end
end

function edgeforobject(object::Any, tail::Vertex, head::Vertex, properties::Dict{String,Any}=Dict{String,Any}())
	# Construct an edge for a specified object, and  a pair of vertices with a set of property values

	e = Edge(tail, head, properties)
	e.containedobject = object

	return e
end

function edgeforobject(typelabel::String, object::Any, tail::Vertex, head::Vertex, properties::Dict{String,Any}=Dict{String,Any}())
	# Construct an edge with a typelabel for a specified object, and  a pair of vertices with a set of property values

	e = Edge(typelabel, tail, head, properties)
	e.containedobject = object

	return e
end
