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
const DistinctResultOption = QueryResultOption("DistinctResultOption")
const MoveToVerticesResultOption = QueryResultOption("MoveToVerticesResultOption")
const MoveToEdgesResultOption = QueryResultOption("MoveToEdgesResultOption")
const StoreResultOption = QueryResultOption("StoreResultOption")

type CompositeQuery
	# Represents a Query in its entirety, or a portion of a larger Query

	graph::Graph
	previous::CompositeQuery
	associatedfunction::Function
	inputtype::QueryResultType
	outputtype::QueryResultType
	option::QueryResultOption
	depth::Integer
	result::Any
	isrealised::Bool
	isgrouped::Bool

	function CompositeQuery(g::Graph, outputtype::QueryResultType, option::QueryResultOption)
		# Constructs a CompositeQuery for the specified Graph

		cq = new()
		cq.graph = g
		cq.inputtype = InitialQueryResult
		cq.outputtype = outputtype
		cq.option = option
		cq.depth = 1
		cq.isrealised = false
		cq.isgrouped = false
		cq.result = Set{CompositeQueryResultItem}()

		return cq
	end

	function CompositeQuery(g::Graph, outputtype::QueryResultType, option::QueryResultOption, associatedfunction::Function)
		# Constructs a CompositeQuery for the specified Graph with a specified where filter

		cq = CompositeQuery(g, outputtype, option)
		cq.associatedfunction = associatedfunction

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

	function CompositeQuery(previous::CompositeQuery, outputtype::QueryResultType, option::QueryResultOption, associatedfunction::Function)
		# Constructs a CompositeQuery which extends a previous query and has an initial where filter function

		cq = CompositeQuery(previous, outputtype, option)
		cq.associatedfunction = associatedfunction

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

function distinct(cq::CompositeQuery)
	# Operation that filters the current set of results to a distinct set
	return CompositeQuery(cq, cq.outputtype, DistinctResultOption)
end

function store(cq::CompositeQuery, select::Function)
	# Operation that stores data to be carried forward in the query
	return CompositeQuery(cq, cq.outputtype, StoreResultOption, select)
end

function movetoedges(cq::CompositeQuery, select::Function)
	# Operation that moves to a previously stored set of edges
	return CompositeQuery(cq, EdgeSetQueryResult, MoveToEdgesResultOption, select)
end

function movetovertices(cq::CompositeQuery, select::Function)
	# Operation that moves to a previously stored set of edges
	return CompositeQuery(cq, VertexSetQueryResult, MoveToVerticesResultOption, select)
end

function select(cq::CompositeQuery, select::Function)
	# executes the query and returns a set of mapped results
	if !cq.isrealised
		realise!(cq)
	end

	results = Set{Any}()

	if isspecified(cq.result)
		for r in cq.result
			push!(results, select(r))
		end
	end

	return results
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

function group(cq::CompositeQuery, groupby::Function)
	# groups the results of a composite query
	if !cq.isrealised
		realise!(cq)
	end

	if !isdefined(cq, :result)
		throw (CompositeQueryResultNotRealisedException())
	end

	groupedresult = Dict{Any, CompositeQuery}()

	if isspecified(cq.result)
		for r in cq.result
			key = groupby(r)

			groupset = Base.get(groupedresult, key, UnspecifiedValue)

			if groupset == UnspecifiedValue
				groupset = CompositeQuery(cq, cq.outputtype, NoneQueryResultOption, groupby)
				groupedresult[key] = groupset
				groupset.isrealised = true
			end

			push!(groupset.result, r)
		end
	end

	return groupedresult
end

function isspecified(value::Any)
	# Tests whether a value is specified (whether it matches the UnspecifiedValue)

	return value != UnspecifiedValue
end

function getdistinctresults(cq)
	# An operation that selects the distinct set of Vertices or Edges resulting from the previous query.  A new CompositeQuery is constructed which includes the distinct operation.
	if !cq.isrealised
		realise!(cq)
	end

	if !isdefined(cq, :result)
		throw (CompositeQueryResultNotRealisedException())
	end

	# the implementation of this method based on the implementation of unique in base library
	distinctset = Set{Container}()
	newresults = Set{CompositeQueryResultItem}()

	if isspecified(cq.result)
		for r in cq.result
			if !in(r.item, distinctset)
				push!(distinctset, r.item)
				push!(newresults, CompositeQueryResultItem(r.item, r))
			end
		end
	end

	return newresults
end

function realise!(cq::CompositeQuery)
	# realise each part of the composite query in turn
	# there is alot of scope for optimisation here to combine parts of the composite query
	if !cq.isrealised
		# ensure previous parts of the query are realised first
		if isdefined(cq, :previous) && !cq.previous.isrealised
			realise!(cq.previous)
		end

		if cq.outputtype != EdgeSetQueryResult && cq.outputtype != VertexSetQueryResult
			# throw
			throw(InvalidOutputQueryResultTypeException())
		end

		source = Set{CompositeQueryResultItem}()

		if cq.inputtype == InitialQueryResult
			items = Set{Container}()
			if cq.outputtype == EdgeSetQueryResult
				items = values(cq.graph.edges)
			elseif cq.outputtype == VertexSetQueryResult
				items = values(cq.graph.vertices)
			else
				throw(InvalidInputQueryResultTypeException())
			end
			for i in items
				push!(source, CompositeQueryResultItem(i))
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

		if cq.option == StoreResultOption
			for r in source
				newresultitem = CompositeQueryResultItem(r.item, r)
				push!(cq.result, newresultitem)

				values = cq.associatedfunction(newresultitem)
				if isspecified(values)
					merge!(newresultitem.storedvalues, values)
				end
			end
		elseif cq.option == MoveToVerticesResultOption
			for r in source
				item = cq.associatedfunction(r)
				if isspecified(item)
					if isa(item,Vertex)
						newresultitem = CompositeQueryResultItem(item, r)
						push!(cq.result, newresultitem)
					else
						throw(UnexpectedTypeOnMoveToVertices())
					end
				end
			end
		elseif cq.option == MoveToEdgesResultOption
			for r in source
				item = cq.associatedfunction(r)
				if isspecified(item)
					if isa(item,Edge)
						newresultitem = CompositeQueryResultItem(item, r)
						push!(cq.result, newresultitem)
					else
						throw(UnexpectedTypeOnMoveToEdges())
					end
				end
			end
		elseif cq.option == DistinctResultOption
			cq.result = getdistinctresults(cq.previous)
		else
			# default the getitem function to returning the item given
			getitem = r -> r.item
			getitemsubset = UnspecifiedValue

			if cq.inputtype == cq.outputtype || cq.inputtype == InitialQueryResult
				# nothing to do
			elseif cq.inputtype == EdgeSetQueryResult && cq.outputtype == VertexSetQueryResult
				if cq.option == HeadQueryResultOption
					getitem = (r -> r.item.head)
				elseif cq.option == TailQueryResultOption
					getitem = (r -> r.item.tail)
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
						cqi = CompositeQueryResultItem(si, r)
						if doesitemmatchquery(cqi, cq)
							push!(cq.result, cqi)
						end
					end
				else
					cqi = CompositeQueryResultItem(item, r)
					if doesitemmatchquery(cqi, cq)
						push!(cq.result, cqi)
					end
				end
			end
		end

		cq.isrealised = true
	end
end

function doesitemmatchquery(resultitem::CompositeQueryResultItem, cq::CompositeQuery)
	# test whether a CompositeQueryResultItem matches the conditions for inclusion in a query
	match = true

	if isdefined(cq, :associatedfunction)
		match = cq.associatedfunction(resultitem)
	end

	return match
end

# A union of the types that may be used as a source of queries
QuerySource = Union(Graph,CompositeQuery,Dict{Any,CompositeQuery})

# A union of the types that may be used as operations of a query
QueryOperation = Union(Function,(Function, Function))

function query(source::QuerySource,operations::QueryOperation...)
	# Builds a query from a source and series of operations

	current = source
	isgrouped = false
	operationindex = 1

	for operation in operations
		if isa(current, Dict{Any,CompositeQuery})
			isgrouped = true
			break
		end

		if isa(operation,Function)
			current = operation(current)
		elseif isa(operation, (Function,Function))
			current = operation[1](current, operation[2])
		end

		operationindex = operationindex + 1
	end

	if isgrouped && length(operations) >= operationindex
		remainingoperations = operations[operationindex:length(operations)]

		groupedresult = Dict{Any, Any}()

		for (k,v) in current
			push!(groupedresult, k, query(v, remainingoperations...))
		end

		return groupedresult
	else
		return current
	end
end
