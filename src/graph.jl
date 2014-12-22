type Graph <: Container
	# Represents a Property Graph

	id::UUID.Uuid
	containedobject::Any
	attachedproperties::Dict{String,Any}

	edges::Dict{UUID.Uuid,Edge}
	vertices::Dict{UUID.Uuid,Vertex}

	# tracker defined ::Any instead of ::ChangeTracker
	# in order to avoid mutually circular type declaration
	# see: https://github.com/JuliaLang/julia/issues/269
	tracker::Any

	# a default graph loader for this graph
	defaultloader::Any

	function Graph(properties::Dict{String,Any}=Dict{String,Any}())
		# Constructs a Property Graph with a set of property values

		g = new()
		g.id = UUID.v4()

		g.attachedproperties = properties

		g.edges = Dict{UUID.Uuid,Edge}()
		g.vertices = Dict{UUID.Uuid,Vertex}()

		# leave loader and tracker unspecified by default

		return g
	end

	function Graph(object::Any, properties::Dict{String,Any}=Dict{String,Any}())
		# Construct a Property Graph for a supplied object and with a set of property values

		g = Graph(properties)
		g.containedobject = object

		return g
	end
end

function add!(g::Graph, v::Vertex, withtracking::Bool = true)
	# Add a vertex to the graph

	# test whether the vertex already belongs to another graph
	if isdefined(v, :graph) && v.graph != g
		throw(VertexAlreadyBelongsToAnotherGraphException())
	end

	# test whether the vertex already belongs to this graph
	if isdefined(v, :graph) && v.graph == g
		throw(VertexAlreadyBelongsToSpecifiedGraphException())
	end

	v.graph = g

	if withtracking
		trackadd(v)
	end

	g.vertices[v.id] = v

	return v
end


function remove!(g::Graph, e::Edge, withtracking::Bool = true)
	belongstograph = false

	# test whether the edge belongs to this graph
	if isdefined(e,:graph) && e.graph == g
		belongstograph = true
	end

	if !belongstograph
		throw(EdgeDoesNotBelongToGraphException())
	end

	if withtracking
		trackremove(e)
	end

	delete!(g.edges, e.id)
	delete!(e.tail.outgoingedges, e)
	delete!(e.head.incomingedges, e)
end

function remove!(g::Graph, v::Vertex, withtracking::Bool = true)
	belongstograph = false

	# test whether the edge belongs to this graph
	if isdefined(v,:graph) && v.graph == g
		belongstograph = true
	end

	if !belongstograph
		throw(VertexDoesNotBelongToGraphException())
	end

	edgestoremove = Set{Edge}()

	for e in v.incomingedges
		push!(edgestoremove, e)
	end

	for e in v.outgoingedges
		push!(edgestoremove, e)
	end

	for e in edgestoremove
		remove!(g, e, withtracking)
	end

	if withtracking
		trackremove(v)
	end

	delete!(g.vertices, v)
end

function add!(g::Graph, e::Edge, withtracking::Bool = true)
	# Add an Edge to the Graph

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

	if withtracking
		trackadd(e)
	end

	g.edges[e.id] = e
	push!(e.head.incomingedges,e)
	push!(e.tail.outgoingedges,e)

	return e
end

function gettracker(g::Graph)
	associatedtracker = UnspecifiedValue

	if isdefined(g, :tracker)
		associatedtracker = g.tracker
	end

	return associatedtracker
end
