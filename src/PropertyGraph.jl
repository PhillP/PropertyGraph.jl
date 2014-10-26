module PropertyGraph

using UUID

# type exports
export Graph, Vertex, Edge, Container, CompositeQuery
export EdgeForObject, VertexForObject
# Exceptions.jl exports
export VertexAlreadyBelongsToAnotherGraphException, EdgeAlreadyBelongsToAnotherGraphException
export VertexAlreadyBelongsToSpecifiedGraphException, EdgeAlreadyBelongsToSpecifiedGraphException
export EdgeTailDoesNotBelongToGraphException, EdgeHeadDoesNotBelongToGraphException
export InvalidQueryOptionOutputTypeCombinationException, InvalidInputQueryResultTypeException
export InvalidOutputQueryResultTypeException, MissingPreviousQueryContextException
export MissingPreviousQueryContextResultException, InvalidQueryOptionOutputTypeCombinationException
export InvalidInputOutputQueryOptionCombinationException, CompositeQueryResultNotRealisedException
# Container.jl exports
export setPropertyValue!, setPropertyValues!,get, UnspecifiedValue
# Vertex.jl exports
# Edge.jl exports
# Graph.jl exports
export add!
# CompositeQuery.jl exports
export InitialQueryResult, VertexSetQueryResult, EdgeSetQueryResult
export vertices, edges, outgoing, incoming, head, tail
export reduce, sum, maximum, minimum, average, count
export distinct, realise!
export QuerySource, QueryOperation, query

include("exceptions.jl")
include("container.jl")
include("vertex.jl")
include("edge.jl")
include("graph.jl")
include("compositequery.jl")

end # module
