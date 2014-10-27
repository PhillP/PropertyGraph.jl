# PropertyGraph

[![Build Status](https://travis-ci.org/PhillP/PropertyGraph.jl.svg?branch=master)](https://travis-ci.org/PhillP/PropertyGraph.jl)

PropertyGraph.jl is a Julia package for creating and querying graph data structures.  A Graph consists of Vertices connected by Edges.  Each Vertex and Edge has properties, an identifier and optionally a reference to any arbitrary object.

## Querying

Querying in PropertyGraph.jl is performed by:
 - building up a query object (::CompositeQuery) that contains a list of graph traversals and operations to be performed.
 - retrieving results from the query (which causes the query to execute when needed)

A query, or portions of a query can be reused; and this avoids repeat processing of the same traversals.

The simplest way of building a query is  to use the query varargs method.  This method allows queries to be written as a list of operations in a simple DSL as per the following example.
```
averagepopulaton = query(graph, # start with a graph
			  (vertices, v-> get(v,"name") == "Queensland" || get(v,"name") == "Victoria"), # select the vertices that match some condition
			  (outgoing, e->e.typelabel == "IsAdjacent"), # follow the outgoing edges from these vertices where the edges are of type IsAdjacent
			  head, # move to the vertices at the head of those edges
			  distinct, # retain only 1 instance of each vertex(as some vertexes may have been reached by more than 1 path)
			  (average, v->get(v, "population") # average the value of population property
			 )
```

The above example and others are explained in the [wiki](https://github.com/PhillP/PropertyGraph.jl/wiki).

For the moment, Graphs must be held entirely in memory.  This is an area for future development.

## Installation

*Installation through the Package manager is not yet available.  These instructions can not be used until metadata for the package is registered*

Install PropertyGraph.jl with:
```
Not yet available: Pkg.add("PropertyGraph")
```

If PropertyGraph.jl is not recognised you may first need to update your package metadata with:
```
Pkg.update()
```

PropertyGraph.jl has a dependency on the following 2 packages:
- the [Compat](https://github.com/JuliaLang/Compat.jl) package for Julia 0.3/0.4 compatibility
- the [UUID](https://github.com/forio/UUID.jl) for generation of unique identifiers

## Roadmap

There are several key areas for developemnt:
 - extend query capabilities
 - integration with [DataFrames](https://github.com/JuliaStats/DataFrames.jl) (using DataFrames as a source for building graphs, and generating query results as DataFrames)
 - reading and writing graphs from various formats
 - reading (on-demand) and writing to/from persistent stores

## Inspiration

There are various sources of inspiration for this package, including the [Gremlin](https://github.com/tinkerpop/gremlin/wiki) graph traversal language for the JVM.  However, an aim is to develop features within this package that will be of most benefit to Julia users.

## Documentation

The documentation for PropertyGraph.jl will be available on the [wiki](https://github.com/PhillP/PropertyGraph.jl/wiki).
