# An exception type thrown when a method stub is called.
type NotImplementedException <: Exception end

# An exception type thrown when a Vertex is added to a graph that already belongs to another graph
type VertexAlreadyBelongsToAnotherGraphException <: Exception end
type VertexAlreadyBelongsToSpecifiedGraphException <: Exception end
# An exception type thrown when an Edge is added to a graph that already belongs to another graph
type EdgeAlreadyBelongsToAnotherGraphException <: Exception end
type EdgeAlreadyBelongsToSpecifiedGraphException <: Exception end
# An exception type thrown when the tail of an edge being added does not belong to the graph
type EdgeTailDoesNotBelongToGraphException <: Exception end
# An exception type thrown when the head of an edge being added does not belong to the graph
type EdgeHeadDoesNotBelongToGraphException <: Exception end

type InvalidQueryOptionOutputTypeCombinationException <: Exception end

type InvalidInputQueryResultTypeException <: Exception end
type InvalidOutputQueryResultTypeException <: Exception end
type MissingPreviousQueryContextException <: Exception end
type MissingPreviousQueryContextResultException <: Exception end
type InvalidQueryOptionOutputTypeCombinationException <: Exception end
type InvalidInputOutputQueryOptionCombinationException <: Exception end
type CompositeQueryResultNotRealisedException <: Exception end
