# PropertyGraph

[![Build Status](https://travis-ci.org/PhillP/PropertyGraph.jl.svg?branch=master)](https://travis-ci.org/PhillP/PropertyGraph.jl)

PropertyGraph.jl is a Julia package for creating and querying graph data structures.  A Graph consists of Vertices connected by Edges.  Vertices and Edges each have properties, an identifier and optionally a reference to any arbitrary object so that existing objects can be organised into graphs.

## Documentation

The primary documentation for PropertyGraph.jl is the [wiki](https://github.com/PhillP/PropertyGraph.jl/wiki) which contains guidance, instructions and examples.

## Inspiration

There are various sources of inspiration for this package, including the [Gremlin](https://github.com/tinkerpop/gremlin/wiki) graph traversal language for the JVM, the Cypher language used by Neo4j and other query languages.  However, the structure of queries supported by this package make use of features and syntax peculiar to Julia.

## Querying

Querying in PropertyGraph.jl is performed by:
 - building up a query object (::CompositeQuery) that contains a list of graph traversals and operations to be performed.
 - retrieving results from the query (which causes the query to execute when needed)

A query, or portions of a query can be reused to avoid repeat processing of the common traversals.

The simplest way of building a query is  to use the query varargs method.  This method allows queries to be written as a list of operations in a simple DSL as per the following example.
```julia
averagepopulaton = query(graph,
			  (vertices, v-> get(v,"name") == "Queensland" || get(v,"name") == "Victoria"),
			  (outgoing, e->e.typelabel == "IsAdjacent"),
			  head,
			  distinct,
			  (average, v->get(v, "population") # average the value of population property
			 )

# The query above contains the following steps:
	# start with a graph
	# select the vertices that match some condition
	# follow the outgoing edges from these vertices where the edges are of type IsAdjacent
	# move to the vertices at the head of those edges
	# retain only 1 instance of each vertex(as some vertices may have been reached by more than 1 path)
	# average the value of population property
```

The above example and others are explained in the [wiki](https://github.com/PhillP/PropertyGraph.jl/wiki).

For the moment, Graphs must be held entirely in memory.  This is an area for future development.

## Persistence
This library will provide hooks and extension points to support persistence of graphs and the loading of portions of a graph on-demand.  The wiki describes how change tracking is implemented.  A store of changes is provided and can be used by persistence functionality to determine which vertices and edges have change and need to be persisted or removed.

## Performance
The focus of the library has initially been on supporting a useful and convenient query syntax.  There are a number of features that would be required to make this functionality perform well on larger data sets and this will be the subject of future work.

## Installation

Although PropertyGraph.jl is written to be compatible with both Julia 0.3 and 0.4, it will initially be available for Julia 0.4 only.  There have been errors encountered during testing on v0.3 due to issues that have already been resolved in Julia 0.4.

Install PropertyGraph.jl with:
```julia
Pkg.add("PropertyGraph")
```

If PropertyGraph.jl is not recognised you may first need to update your package metadata with:
```julia
Pkg.update()
```

PropertyGraph.jl has a dependency on the following 2 packages:
- the [Compat](https://github.com/JuliaLang/Compat.jl) package for Julia 0.3/0.4 compatibility
- the [UUID](https://github.com/forio/UUID.jl) for generation of unique identifiers
