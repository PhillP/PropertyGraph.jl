abstract GraphLoader

function loadmissingdata(loader::GraphLoader, items::Set{Container})
	# given a partially loaded set of containers (edges or vertices), loading missing data
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

function loadmissingdata(loader::GraphLoader, results::Set{CompositeQueryResultItem})
	# given a partially loaded set of result items, loading missing data
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

function loadvertices(loader::GraphLoader)
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

function loadvertices(loader::GraphLoader, where::Function)
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

function loadvertices(loader::GraphLoader, whereExp::Expr)
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

function loadedges(loader::GraphLoader)
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

function loadedges(loader::GraphLoader, where::Function)
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

function loadedges(loader::GraphLoader, whereExp::Expr)
	throw(NotImplementedException()) # must be implemented for specific graph loader
end

function vertices(loader::GraphLoader)
	# Operation that selects the vertices of a graph.  A CompositeQuery which begins with this operation is constructed.

	cq = vertices(loader.graph)
	cq.loader = loader

	return cq
end

function vertices(loader::GraphLoader, where::Function)
	# Operation that selects the vertices of a graph that match a supplied where condition.  A CompositeQuery which begins with this operation is constructed.
	cq = vertices(loader.graph, where)
	cq.loader = loader

	return cq
end

function vertices(loader::GraphLoader, whereExp::Expr)
	# Operation that selects the vertices of a graph that match a supplied where condition.  A CompositeQuery which begins with this operation is constructed.

	cq = vertices(loader.graph, whereExp)
	cq.loader = loader

	return cq
end

function edges(loader::GraphLoader)
	# Operation that selects the edges of a graph.  A CompositeQuery which begins with this operation is constructed.

	cq = edges(loader.graph)
	cq.loader = loader

	return cq
end

function edges(loader::GraphLoader, where::Function)
	# Operation that selects the edges of a graph that match a specified where condition.  A CompositeQuery which begins with this operation is constructed.

	cq = edges(loader.graph, where)
	cq.loader = loader

	return cq
end

function edges(loader::GraphLoader, whereExpr::Function)
	# Operation that selects the edges of a graph that match a specified where condition.  A CompositeQuery which begins with this operation is constructed.

	cq = edges(loader.graph, whereExpr)
	cq.loader = loader

	return cq
end
