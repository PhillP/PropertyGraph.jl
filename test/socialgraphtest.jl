using Compat
using Base.Test
using PropertyGraph
using UUID

function socialgraphtest()
	graph = buildsocialtestgraph()

	# The social graph in this test is made up of:
	#		- 30 Vertices of type Country, with the following properties:
	#			- Name
	#		- 200 Vertices of type Person, with the following properties:
	#			- Name, Age
	#		- 200 Edges between a Person and a Country, with a type label: "LivesIn" and properties:
	#			- ForYears (indicating how many years the person has lived in the country)
	#		- 1783 Edges between a Person and a Person, with a type label: "Follows" (indicating that one person follows another)

	# count the countries
	@test query(graph, (vertices, v->v.typelabel == "Country"), count) == 30

	# count the people
	@test query(graph, (vertices, v->v.typelabel == "Person"), count) == 200

	# count the LivesIn edges
	@test query(graph, (edges, e->e.typelabel == "LivesIn"), count) == 200

	# count the Follows edges
	@test query(graph, (edges, e->e.typelabel == "Follows"), count) == 1783

	# start with the vertices for Germany and France
	# follow the edges of type "LivesIn" to find all the people within the graph who live in Germany or France
	#     only edges that have a ForYears property of >= 5 (indicating the person has lived in the associated country for 5 or more years) will be followed
	# the tail of each edge is a person, filter the people selected to those with an age property >= 30
	part1 = query(graph,
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
@time socialgraphtest()
