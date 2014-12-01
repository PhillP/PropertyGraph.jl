module PropertyGraph

using UUID

# type exports
export Graph, Vertex, Edge, Container, CompositeQuery, CompositeQueryResultItem, ChangeTracker
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
export EdgeDoesNotBelongToGraphException, VertexDoesNotBelongToGraphException

# Container.jl exports
export setpropertyvalue!, setpropertyvalues!,get, UnspecifiedValue
# Vertex.jl exports
# Edge.jl exports
# Graph.jl exports
export add!, remove!
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
include("graphloader.jl")
include("graph.jl")
include("changetracker.jl")
include("compositequeryresultitem.jl")
include("compositequery.jl")

end # module
