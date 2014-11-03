# Represents types of Query Results
immutable QueryResultType name::String end
const VertexSetQueryResult = QueryResultType("VertexSetQueryResult")
const EdgeSetQueryResult = QueryResultType("EdgeSetQueryResult")
const InitialQueryResult = QueryResultType("InitialQueryResult")

# Represents options for the selection of query results
immutable QueryResultOption name::String end
const IncomingQueryResultOption = QueryResultOption("IncomingQueryResultOption")
const OutgoingQueryResultOption = QueryResultOption("OutgoingQueryResultOption")
const HeadQueryResultOption = QueryResultOption("HeadQueryResultOption")
const TailQueryResultOption = QueryResultOption("TailQueryResultOption")
const NoneQueryResultOption = QueryResultOption("NoneQueryResultOption")

type CompositeQuery
	# Represents a Query in its entirety, or a portion of a larger Query

	graph::Graph
	previous::CompositeQuery
	where::Function
	inputtype::QueryResultType
	outputtype::QueryResultType
	option::QueryResultOption
	depth::Integer
	result::Any
	isrealised::Bool

	function CompositeQuery(g::Graph, outputtype::QueryResultType, option::QueryResultOption)
		# Constructs a CompositeQuery for the specified Graph

		cq = new()
		cq.graph = g
		cq.inputtype = InitialQueryResult
		cq.outputtype = outputtype
		cq.option = option
		cq.depth = 1
		cq.isrealised = false

		return cq
	end

	function CompositeQuery(g::Graph, outputtype::QueryResultType, option::QueryResultOption, where::Function)
		# Constructs a CompositeQuery for the specified Graph with a specified where filter

		cq = CompositeQuery(g, outputtype, option)
		cq.where = where

		return cq
	end

	function CompositeQuery(previous::CompositeQuery, outputtype::QueryResultType, option::QueryResultOption)
		# Constructs a CompositeQuery which extends a previous query

		cq = CompositeQuery(previous.graph, outputtype, option)
		cq.previous = previous
		cq.inputtype = previous.outputtype
		cq.outputtype = outputtype
		cq.option = option
		cq.depth = previous.depth + 1

		return cq
	end

	function CompositeQuery(previous::CompositeQuery, outputtype::QueryResultType, option::QueryResultOption, where::Function)
		# Constructs a CompositeQuery which extends a previous query and has an initial where filter function

		cq = CompositeQuery(previous, outputtype, option)
		cq.where = where

		return cq
	end
end

function vertices(g::Graph)
	# Operation that selects the vertices of a graph.  A CompositeQuery which begins with this operation is constructed.

	return CompositeQuery(g, VertexSetQueryResult, NoneQueryResultOption)
end

function vertices(g::Graph, where::Function)
	# Operation that selects the vertices of a graph that match a supplied where condition.  A CompositeQuery which begins with this operation is constructed.

	return CompositeQuery(g, VertexSetQueryResult, NoneQueryResultOption, where)
end

function edges(g::Graph)
	# Operation that selects the edges of a graph.  A CompositeQuery which begins with this operation is constructed.

	return CompositeQuery(g, EdgeSetQueryResult, NoneQueryResultOption)
end

function edges(g::Graph, where::Function)
	# Operation that selects the edges of a graph that match a specified where condition.  A CompositeQuery which begins with this operation is constructed.

	return CompositeQuery(g, EdgeSetQueryResult, NoneQueryResultOption, where)
end

function outgoing(cq::CompositeQuery)
	# Operation that selects the outgoing edges of the Nodes resulting from the supplied query.  A CompositeQuery which extends the previous query to include this operation is returned.

	return CompositeQuery(cq, EdgeSetQueryResult, OutgoingQueryResultOption)
end

function outgoing(cq::CompositeQuery, where::Function)
	# Operation that selects the outgoing edges of the Nodes resulting from the supplied query that match the supplied where condition.  A CompositeQuery which extends the previous query to include this operation is returned.

	return CompositeQuery(cq, EdgeSetQueryResult, OutgoingQueryResultOption, where)
end

function incoming(cq::CompositeQuery)
	# Operation that selects the incoming edges of the Nodes resulting from the supplied query.  A CompositeQuery which extends the previous query to include this operation is returned.
	return CompositeQuery(cq, EdgeSetQueryResult, IncomingQueryResultOption)
end

function incoming(cq::CompositeQuery, where::Function)
	# Operation that selects the incoming edges of the Nodes resulting from the supplied query that match the supplied where function.  A CompositeQuery which extends the previous query to include this operation is returned.

	return CompositeQuery(cq, EdgeSetQueryResult, IncomingQueryResultOption, where)
end

function head(cq::CompositeQuery)
	# Operation that selects the Vertices at the head of the edges resulting from the supplied query.  A CompositeQuery which extends the previous query to include this operation is returned.

	return CompositeQuery(cq, VertexSetQueryResult, HeadQueryResultOption)
end

function head(cq::CompositeQuery, where::Function)
	# Operation that selects the Vertices at the head of the edges resulting from the supplied query that match the supplied where function.  A CompositeQuery which extends the previous query to include this operation is returned.

	return CompositeQuery(cq, VertexSetQueryResult, HeadQueryResultOption, where)
end

function tail(cq::CompositeQuery)
	# Operation that selects the Vertices at the tail of the edges resulting from the supplied query.  A CompositeQuery which extends the previous query to include this operation is returned.

	return CompositeQuery(cq, VertexSetQueryResult, TailQueryResultOption)
end

function tail(cq::CompositeQuery, where::Function)
	# Operation that selects the Vertices at the tail of the edges resulting from the supplied query that match the supplied where function.  A CompositeQuery which extends the previous query to include this operation is returned.

	return CompositeQuery(cq, VertexSetQueryResult, TailQueryResultOption, where)
end

function reduce(reducer::Function, cq::CompositeQuery, mapper::Function)
	# Performs a map reduce operation on the Edges or Vertices resulting from a query

	if !cq.isrealised
		realise!(cq)
	end

	if !isdefined(cq, :result)
		throw (CompositeQueryResultNotRealisedException())
	end

	currentvalue::Any = UnspecifiedValue
	if isspecified(cq.result)
		for r in cq.result
			currentvalue = reducer(currentvalue, mapper(r))
		end
	end

	return currentvalue
end

function sum(cq::CompositeQuery, map::Function)
	# Sums the values mapped from the Vertices or Edges resulting from the supplied query by using the supplied map function

	return reduce(cq, map) do x,y
			if isspecified(x) && isspecified(y)
				x + y
			else
				y
			end
		end
end

function maximum(cq::CompositeQuery, map::Function)
	# Returns the maximum of the values mapped from the Vertices or Edges resulting from the supplied query using the supplied map function

	return reduce(cq, map) do x,y
			if isspecified(x) && isspecified(y) && x > y
				x
			else
				y
			end
		end
end

function minimum(cq::CompositeQuery, map::Function)
	# Returns the minimum of the values mapped from the Vertices or Edges resulting from the supplied query by using the supplied map function

	return reduce(cq, map) do x,y
			if isspecified(x) && isspecified(y) && x < y
				x
			else
				y
			end
		end
end

function count(cq::CompositeQuery)
	# Returns the count of the  Vertices or Edges resulting from the supplied query

	result = reduce(cq, n -> 1) do x, y
			if isspecified(x) && isspecified(y)
				x + y
			else
				y
			end
		end

	if !isspecified(result)
		result = 0
	end

	return result
end

function average(cq::CompositeQuery, map::Function)
	# Returns the average of the  values mapped from the Vertices or Edges resulting from the supplied query by using the supplied map function

	result = UnspecifiedValue

	countresult = count(cq)

	if countresult > 0
		sum_result = sum(cq, map)
		result = sum_result / countresult
	end

	return result
end

function isspecified(value::Any)
	# Tests whether a value is specified (whether it matches the UnspecifiedValue)

	return value != UnspecifiedValue
end

function distinct(cq::CompositeQuery)
	# An operation that selects the distinct set of Vertices or Edges resulting from the previous query.  A new CompositeQuery is constructed which includes the distinct operation.
	if !cq.isrealised
		realise!(cq)
	end

	if !isdefined(cq, :result)
		throw (CompositeQueryResultNotRealisedException())
	end

	# the implementation of this method based on the implementation of unique in base library
	distinctset = Set{eltype(cq.result)}()

	for r in cq.result
		if !in(r, distinctset)
			push!(distinctset, r)
		end
	end

	return cq
end

function realise!(cq::CompositeQuery)
	# realise each part of the composite query in turn
	# there is alot of scope for optimisation here to combine parts of the composite query
	if !cq.isrealised
		# ensure previous parts of the query are realised first
		if isdefined(cq, :previous) && !cq.previous.isrealised
			realise!(cq.previous)
		end

		result = Set{Edge}()

		if cq.outputtype == EdgeSetQueryResult
			result = Set{Edge}()
		elseif cq.outputtype == VertexSetQueryResult
			result = Set{Vertex}()
		else
			# throw
			throw(InvalidOutputQueryResultTypeException())
		end

		source = Set{Edge}()

		if cq.inputtype == InitialQueryResult
			if cq.outputtype == EdgeSetQueryResult
				source = values(cq.graph.edges)
			elseif cq.outputtype == VertexSetQueryResult
				source = values(cq.graph.vertices)
			else
				throw(InvalidInputQueryResultTypeException())
			end
		else
			if !isdefined(cq, :previous)
				# throw
				throw(MissingPreviousQueryContextException())
			end

			if !isdefined(cq.previous, :result)
				# throw
				throw(MissingPreviousQueryContextResultException())
			end

			source = cq.previous.result
		end

		# default the getitem function to returning the item given
		getitem = r -> r
		getitemsubset = UnspecifiedValue

		if cq.inputtype == cq.outputtype || cq.inputtype == InitialQueryResult
			# nothing to do
		elseif cq.inputtype == EdgeSetQueryResult && cq.outputtype == VertexSetQueryResult
			if cq.option == HeadQueryResultOption
				getitem = (r -> r.head)
			elseif cq.option == TailQueryResultOption
				getitem = (r -> r.tail)
			else
				# throw
				throw(InvalidQueryOptionOutputTypeCombinationException())
			end
		elseif cq.inputtype == VertexSetQueryResult && cq.outputtype == EdgeSetQueryResult
			if cq.option == IncomingQueryResultOption
				getitemsubset = (r->r.incomingedges)
			elseif cq.option == OutgoingQueryResultOption
				getitemsubset = (r->r.outgoingedges)
			else
				# throw
				throw(InvalidQueryOptionOutputTypeCombinationException())
			end
		else
			#throw
			throw(InvalidInputOutputQueryOptionCombinationException())
		end

		for r in source
			item = getitem(r)

			if getitemsubset != UnspecifiedValue
				subset = getitemsubset(item)
				for si in subset
					if doesitemmatchquery(si, cq)
						push!(result, si)
					end
				end
			else
				if doesitemmatchquery(item, cq)
					push!(result, item)
				end
			end
		end

		cq.result = result
		cq.isrealised = true
	end
end

function doesitemmatchquery(item::Container, cq::CompositeQuery)
	# test whether an item (Vertex or Edge) matches the conditions for inclusion in a query
	match = true

	if isdefined(cq, :where)
		match = cq.where(item)
	end

	return match
end

# A union of the types that may be used as a source of queries
QuerySource = Union(Graph,CompositeQuery)

# A union of the types that may be used as operations of a query
QueryOperation = Union(Function,(Function, Function))

function query(source::QuerySource,operations::QueryOperation...)
	# Builds a query from a source and series of operations

	current = source

	for operation in operations
		if isa(operation,Function)
			current = operation(current)
		elseif isa(operation, (Function,Function))
			current = operation[1](current, operation[2])
		end
	end

	return current
end
