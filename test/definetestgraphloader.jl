using Compat
using Base.Test
using PropertyGraph
using UUID

type TestGraphLoader <: GraphLoader
	# A graph loader that provides edges and vertices from a pair of dictionaries
	# used to test that registered GraphLoader is used as expected by PropertyGraph.jl
	graph::Graph

	created::Dict{UUID.Uuid, Container}
	sourceedges::Dict{UUID.Uuid, Edge}
	sourcevertices::Dict{UUID.Uuid, Vertex}

	function TestGraphLoader(g::Graph)
		# Constructs a GraphLoader for the specified Graph

		gl = new()
		gl.graph = g

		gl.created = Dict{UUID.Uuid,Container}()
		gl.sourceedges = Dict{UUID.Uuid,Edge}()
		gl.sourcevertices = Dict{UUID.Uuid,Vertex}()

		return gl
	end
end

function PropertyGraph.loadmissingdata(loader::TestGraphLoader, e::Edge)
	itemloaded::Bool = false

	if haskey(loader.sourceedges, e.id)
		edge = loader.sourceedges[e.id]
		clearproperties!(e)
		setpropertyvalues!(e, edge.attachedproperties)

		e.partiallyloaded = false

		loadmissingdata(loader, e.head)
		loadmissingdata(loader, e.tail)

		itemloaded = true
	end

	return itemloaded
end

function partialcopy(loader::TestGraphLoader, edge::Edge)
	if haskey(loader.created, edge.id)
		return loader.created[edge.id]
	else
		head = partialcopy(loader, edge.head)
		tail = partialcopy(loader, edge.tail)

		e = Edge(tail, head)
		e.partiallyloaded = true
		e.typelabel = edge.typelabel
		e.id = edge.id

		loader.created[edge.id] = e

		return e
	end
end

function partialcopy(loader::TestGraphLoader, vertex::Vertex)
	if haskey(loader.created, vertex.id)
		return loader.created[vertex.id]
	else
		v = Vertex()
		v.partiallyloaded = true
		v.typelabel = vertex.typelabel
		v.id = vertex.id

		loader.created[vertex.id] = v

		return v
	end
end

function PropertyGraph.loadmissingdata(loader::TestGraphLoader, v::Vertex)
	itemloaded::Bool = false

	if haskey(loader.sourcevertices, v.id)
		vertex = loader.sourcevertices[v.id]
		clearproperties!(v)
		setpropertyvalues!(v, vertex.attachedproperties)

		v.incomingedges = Set{Container}()
		v.outgoingedges = Set{Container}()

		for e in vertex.incomingedges
			push!(v.incomingedges, partialcopy(loader, e))
		end

		for e in vertex.outgoingedges
			push!(v.outgoingedges, partialcopy(loader, e))
		end

		v.partiallyloaded = false
		itemloaded = true
	end

	return itemloaded
end

function PropertyGraph.loadmissingdata(loader::TestGraphLoader, items::Set{Container})
	# given a partially loaded set of containers (edges or vertices), loading missing data
	allloaded::Bool = true

	for i in items
		if i.partiallyloaded
			itemloaded::Bool = loadmissingdata(loader, i)
			allloaded = allloaded && itemloaded
		end
	end

	return allloaded
end

function PropertyGraph.loadmissingdata(loader::GraphLoader, results::Set{CompositeQueryResultItem})
	# given a partially loaded set of containers (edges or vertices), load missing data
	allloaded::Bool = true

	for r in results
		if r.item.partiallyloaded
			allloaded = allloaded && loadmissingdata(loader, r.item)
		end
	end

	return allloaded
end

function PropertyGraph.loadvertices(loader::TestGraphLoader)
	vertices = Set{Vertex}()

	for v in values(loader.sourcevertices)
		push(vertices, partialcopy(loader, v))
	end

	return vertices
end

function PropertyGraph.loadvertices(loader::TestGraphLoader, where::Function)
	vertices = Set{Vertex}()

	for v in values(loader.sourcevertices)
		if where(CompositeQueryResultItem(v))
			push!(vertices, partialcopy(loader, v))
		end
	end

	return vertices
end

function PropertyGraph.loadvertices(loader::TestGraphLoader, whereExp::Expr)
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

function PropertyGraph.loadedges(loader::TestGraphLoader)
	edges = Set{Edge}{}

	for e in values(loader.sourceedges)
		push!(edges, partialcopy(loader, e))
	end

	return edges
end

function PropertyGraph.loadedges(loader::TestGraphLoader, where::Function)
	edges = Set{Edge}{}

	for e in values(loader.sourceedges)
		if where(CompositeQueryResultItem(e))
			push!(edges, partialcopy(loader, e))
		end
	end

	return edges
end

function PropertyGraph.loadedges(loader::TestGraphLoader, whereExp::Expr)
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

