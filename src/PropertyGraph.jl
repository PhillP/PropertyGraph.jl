module PropertyGraph

using UUID

# type exports
export Graph, Vertex, Edge, Container, CompositeQuery, CompositeQueryResultItem
export edgeforobject, vertexforobject
# Exceptions.jl exports
export VertexAlreadyBelongsToAnotherGraphException, EdgeAlreadyBelongsToAnotherGraphException
export VertexAlreadyBelongsToSpecifiedGraphException, EdgeAlreadyBelongsToSpecifiedGraphException
export EdgeTailDoesNotBelongToGraphException, EdgeHeadDoesNotBelongToGraphException
export InvalidQueryOptionOutputTypeCombinationException, InvalidInputQueryResultTypeException
export InvalidOutputQueryResultTypeException, MissingPreviousQueryContextException
export MissingPreviousQueryContextResultException, InvalidQueryOptionOutputTypeCombinationException
export InvalidInputOutputQueryOptionCombinationException, CompositeQueryResultNotRealisedException
export UnexpectedTypeOnMoveToVertices, UnexpectedTypeOnMoveToEdges
# Container.jl exports
export setpropertyvalue!, setpropertyvalues!,get, UnspecifiedValue
# Vertex.jl exports
# Edge.jl exports
# Graph.jl exports
export add!
# CompositeQuery.jl exports
export InitialQueryResult, VertexSetQueryResult, EdgeSetQueryResult
export vertices, edges, outgoing, incoming, head, tail
export reduce, sum, maximum, minimum, average, count, select, group
export movetovertices, movetoedges, store, getstored
export distinct, realise!, merge, mergedistinct, filter, loop, newonly
export previousresultcount, resultcount
export QuerySource, QueryOperation, query

include("exceptions.jl")
include("container.jl")
include("vertex.jl")
include("edge.jl")
include("graph.jl")
include("compositequeryresultitem.jl")
include("compositequery.jl")

end # module
