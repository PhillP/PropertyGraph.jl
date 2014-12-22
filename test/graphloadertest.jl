function graphloadertest()

	# create a graph
	# with no edges or vertices loaded
	g = Graph()
	# create a graph loader for the Graph
	gl = TestGraphLoader(g)

	# use another test method to obtain graph data for the test
	sourcegraph = buildsocialtestgraph()
	# copy this data to the test graph loader
	# this is to act in place of a persistent store from which to load
	gl.sourceedges = sourcegraph.edges
	gl.sourcevertices = sourcegraph.vertices

	# count the countries
	@test query(gl, (vertices, v->v.typelabel == "Country"), count) == 30

	@test query(gl, (vertices, v->v.typelabel == "Country" && get(v,"Name") == "Germany"), count) == 1

	# start with the vertices for Germany and France
	# follow the edges of type "LivesIn" to find all the people within the graph who live in Germany or France
	#     only edges that have a ForYears property of >= 5 (indicating the person has lived in the associated country for 5 or more years) will be followed
	# the tail of each edge is a person, filter the people selected to those with an age property >= 30
	part1 = query(gl,
				(vertices, v->v.typelabel == "Country" && (get(v,"Name") == "Germany" || get(v,"Name") == "France")),
			 	(incoming, e->e.typelabel == "LivesIn" && get(e,"ForYears",0) >= 5),
			  	(tail, v->get(v,"Age",0) >= 30))
	# get a count of these results
	@test query(part1, count) == 10

	# start with the results of the first query
	# follow edges of type "Follows" (in an incoming direction)
	# the tail of each edge is a person who follows a person selected in the first query
	# select a distinct set of vertices (as there may have been multiple edges to each person..as a person could follow more than one person selected by the first query)
	part2 = query(part1,
				(incoming, e->e.typelabel == "Follows"),
			  	tail,
				distinct
			 )
	# get a count of the results
	testcount = query(part2, count)
	@test testcount == 78
end

@time graphloadertest()
