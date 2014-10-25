immutable QueryResultType name::String end
const VertexSetQueryResult = QueryResultType("VertexSetQueryResult")
const EdgeSetQueryResult = QueryResultType("EdgeSetQueryResult")
const InitialQueryResult = QueryResultType("InitialQueryResult")

immutable QueryResultOption name::String end
const IncomingQueryResultOption = QueryResultOption("IncomingQueryResultOption")
const OutgoingQueryResultOption = QueryResultOption("OutgoingQueryResultOption")
const HeadQueryResultOption = QueryResultOption("HeadQueryResultOption")
const TailQueryResultOption = QueryResultOption("TailQueryResultOption")
const NoneQueryResultOption = QueryResultOption("NoneQueryResultOption")

type CompositeQuery
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
		cq = CompositeQuery(g, outputtype, option)
		cq.where = where

		return cq
	end

	function CompositeQuery(previous::CompositeQuery, outputtype::QueryResultType, option::QueryResultOption)
		cq = CompositeQuery(previous.graph, outputtype, option)
		cq.previous = previous
		cq.inputtype = previous.outputtype
		cq.outputtype = outputtype
		cq.option = option
		cq.depth = previous.depth + 1

		return cq
	end

	function CompositeQuery(previous::CompositeQuery, outputtype::QueryResultType, option::QueryResultOption, where::Function)
		cq = CompositeQuery(previous, outputtype, option)
		cq.where = where

		return cq
	end
end

function vertices(g::Graph)
	return CompositeQuery(g, VertexSetQueryResult, NoneQueryResultOption)
end

function vertices(g::Graph, where::Function)
	return CompositeQuery(g, VertexSetQueryResult, NoneQueryResultOption, where)
end

function edges(g::Graph)
	return CompositeQuery(g, EdgeSetQueryResult, NoneQueryResultOption)
end

function edges(g::Graph, where::Function)
	return CompositeQuery(g, EdgeSetQueryResult, NoneQueryResultOption, where)
end

function outgoing(cq::CompositeQuery)
	return CompositeQuery(cq, EdgeSetQueryResult, OutgoingQueryResultOption)
end

function outgoing(cq::CompositeQuery, where::Function)
	return CompositeQuery(cq, EdgeSetQueryResult, OutgoingQueryResultOption, where)
end

function incoming(cq::CompositeQuery)
	# need to differentiate incoming and outgoing
	return CompositeQuery(cq, EdgeSetQueryResult, IncomingQueryResultOption)
end

function incoming(cq::CompositeQuery, where::Function)
	# need to differentiate incoming and outgoing
	return CompositeQuery(cq, EdgeSetQueryResult, IncomingQueryResultOption, where)
end

function head(cq::CompositeQuery)
	return CompositeQuery(cq, VertexSetQueryResult, HeadQueryResultOption)
end

function head(cq::CompositeQuery, where::Function)
	return CompositeQuery(cq, VertexSetQueryResult, HeadQueryResultOption, where)
end

function tail(cq::CompositeQuery)
	return CompositeQuery(cq, VertexSetQueryResult, TailQueryResultOption)
end

function tail(cq::CompositeQuery, where::Function)
	return CompositeQuery(cq, VertexSetQueryResult, TailQueryResultOption, where)
end

function reduce(reducer::Function, cq::CompositeQuery, mapper::Function)
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
	return reduce(cq, map) do x,y
			if isspecified(x) && isspecified(y)
				x + y
			else
				y
			end
		end
end

function maximum(cq::CompositeQuery, map::Function)
	return reduce(cq, map) do x,y
			if isspecified(x) && isspecified(y) && x > y
				x
			else
				y
			end
		end
end

function minimum(cq::CompositeQuery, map::Function)
	return reduce(cq, map) do x,y
			if isspecified(x) && isspecified(y) && x < y
				x
			else
				y
			end
		end
end

function count(cq::CompositeQuery)
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
	result = UnspecifiedValue

	countresult = count(cq)

	if countresult > 0
		sum_result = sum(cq, map)
		result = sum_result / countresult
	end

	return result
end

function isspecified(value::Any)
	return value != UnspecifiedValue
end

function distinct(cq::CompositeQuery)
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
	match = true

	if isdefined(cq, :where)
		match = cq.where(item)
	end

	return match
end

