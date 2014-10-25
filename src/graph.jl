type Graph <: Container
	id::UUID.Uuid
	containedobject::Any
	attachedproperties::Dict{String,Any}

	edges::Dict{UUID.Uuid,Edge}
	vertices::Dict{UUID.Uuid,Vertex}

	function Graph(properties::Dict{String,Any}=Dict{String,Any}())
		g = new()
		g.id = UUID.v4()

		g.attachedproperties = properties

		g.edges = Dict{UUID.Uuid,Edge}()
		g.vertices = Dict{UUID.Uuid,Vertex}()

		return g
	end

	function Graph(object::Any, properties::Dict{String,Any}=Dict{String,Any}())
		g = Graph(properties)
		g.containedobject = object

		return g
	end
end

function add!(g::Graph, v::Vertex)
	# test whether the vertex already belongs to another graph
	if isdefined(v, :graph) && v.graph != g
		throw(VertexAlreadyBelongsToAnotherGraphException())
	end

	# test whether the vertex already belongs to this graph
	if isdefined(v, :graph) && v.graph == g
		throw(VertexAlreadyBelongsToSpecifiedGraphException())
	end

	v.graph = g
	g.vertices[v.id] = v

	return v
end

function add!(g::Graph, e::Edge)
	# test whether the edge already belongs to another graph
	if isdefined(e,:graph) && e.graph != g
			throw(EdgeAlreadyBelongsToAnotherGraphException())
	end

	# test whether the edge already belongs to this graph
	if isdefined(e,:graph) && e.graph == g
			throw(EdgeAlreadyBelongsToSpecifiedGraphException())
	end

	#ensure that the tail referenced by the edge does in fact belong to this graph
	if !isdefined(e, :tail) || !isdefined(e.tail, :graph) || e.tail.graph != g
		throw(EdgeTailDoesNotBelongToGraphException())
	end

	#ensure that the head referenced by the edge does in fact belong to this graph
	if !isdefined(e,:head) || !isdefined(e.head, :graph) || e.head.graph != g
		throw(EdgeHeadDoesNotBelongToGraphException())
	end

	e.graph = g
	g.edges[e.id] = e
	push!(e.head.incomingedges,e)
	push!(e.tail.outgoingedges,e)

	return e
end
