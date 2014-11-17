using Base.Test
using PropertyGraph
using UUID

# Uncomment this include when running this test directly....
# this include is not required when running vi runtests.jl
# include("testdata.jl")

# run the test within a function scope to avoid interference with other tests
function compositequerytest()
	# build a test graph that will be used to test graph queries
	g = buildstatetestgraph()

	# start with Queensland and Victoria
	q = vertices(g, v-> get(v,"name") == "Queensland" || get(v,"name") == "Victoria")
	# follow outgoung edges of type AdjacentTo
	q = outgoing(q, e->e.typelabel == "IsAdjacent")
	# and include the vertices the edges lead to
	q = head(q)
	# reduce the set to the distinct set
	q = distinct(q)

	# count adjacent states
	countadjacentstates = count(q)
	# expect 3 adjacent states (new south wales, northern territory, south australia)
	@test countadjacentstates == 3

	# and take the sum of the population
	sumadjacentpopulations = sum(q, v->get(v, "population"))
	# expect the sum of the populations from (new south wales, northern territory, south australia)
	@test sumadjacentpopulations == 9355700

	# retrieve the minimum of the population
	minimumadjacentpopulation = minimum(q, v->get(v, "population"))
	# expect the minimum of the adjacent populations to be the population of northern territory
	@test minimumadjacentpopulation == 241800

	# retrieve the maximum of the population
	maximumadjacentpopulation = maximum(q, v->get(v, "population"))
	# expect the maximum of the adjacent populations to be the population of new south wales
	@test maximumadjacentpopulation == 7439200

	# calculate the average of the adjacent populations
	averageadjacentpopulation = average(q, v->get(v, "population"))
	# expect the maximum of the adjacent populations to be the population of new south wales
	@test ifloor(averageadjacentpopulation) == 3118566

	# test short form queries
	countadjacentstates = query(g,
			  (vertices, v-> get(v,"name") == "Queensland" || get(v,"name") == "Victoria"),
			  (outgoing, e->e.typelabel == "IsAdjacent"),
			  head,
			  distinct,
			  count
			 )
	@test countadjacentstates == 3

	averageadjacentpopulation = query(g,
				 (vertices, v-> get(v,"name") == "Queensland1" || get(v,"name") == "Victoria1"),
				 (outgoing, e->e.typelabel == "IsAdjacent"),
				 head,
				 distinct,
				 (average, v->get(v, "population"))
			)
	@test averageadjacentpopulation == UnspecifiedValue

	#test building the query in parts
	q = query(g,
				(vertices, v-> get(v,"name") == "Queensland" || get(v,"name") == "Victoria"),
			 	(outgoing, e->e.typelabel == "IsAdjacent"),
			 )
	# build the rest of the query
	averageadjacentpopulation = query(q,
				 head,
				 distinct,
				 (average, v->get(v, "population"))
			 )
	@test ifloor(averageadjacentpopulation) == 3118566

	# get the state capitals whose population is > 10% of their nations population
	# this query has the following structure
	#       start with a graph
	#       select vertices of type "Country"
	#       store the countries population (so that it will be carried forward with graph traversals for later comparison)
	#       follow the incoming edges of type IsIn to move to States of each Country
	#       the tail of each edge is a State
	#       follow the incoming edges of type IsCaptitalOf
	#       the tail of these edges are capital cities, filter to only those with a population > 10% of stored country population
	q = query(g,
				(vertices, v-> v.typelabel == "Country"),
			 	(store, v->@compat Dict{String, Any}("countrypopulation"=>get(v,"population",0),"countryname"=>get(v,"name"))),
			  	(incoming, e->e.typelabel == "IsIn"),
				tail,
			  	(incoming, e->e.typelabel == "IsCapitalOf"),
				(tail, v->get(v,"population",0) > getstored(v,"countrypopulation",0) * 0.10)
			 )
	countcities = query(q, count)
	@test countcities == 2 # in this test, 2 cities are expected

	# select a flat set of results in the form:  cityname, citypopulation, countryname, countrypopulation
	selectresults = query(q, (select, s->(get(s,"name"),
								 get(s,"population"),
								 getstored(s,"countryname"),
								 getstored(s,"countrypopulation"))))

	@test length(selectresults) == countcities

	# test the data expected was returned
	sydneymatched = false
	melbournematched = false

	for r in selectresults
		if r[1] == "Sydney"
			sydneymatched = true
			@test r[1] == "Sydney"
			@test r[2] == 4667283
			@test r[3] == "Australia"
			@test r[4] == 23235800
		end
		if r[1] == "Melbourne"
			melbournematched = true
			@test r[1] == "Melbourne"
			@test r[2] == 4246345
			@test r[3] == "Australia"
			@test r[4] == 23235800
		end
	end

	@test sydneymatched
	@test melbournematched

	# find the States whose capitals have more than half the State's population
	# this can be achieved in several ways... however for this stest Store and Move is being targetted for testing
	# once the cities are identified, movetovertex is used to move back to previously stored State vertices
	populationquery = query(g,
				(vertices, v-> v.typelabel == "State"),
			 	(store, v->@compat Dict{String, Any}("state"=>v.item, "statepopulation"=>get(v, "population"))),
			  	(incoming, e->e.typelabel == "IsCapitalOf"),
				(tail, v->get(v,"population",0) > (getstored(v,"statepopulation",0) * 0.5)),
			  	(movetovertices, v->getstored(v,"state")) # move back to State
			 )

	sumpopulation = query(populationquery, (sum, v->get(v,"population")))
	@test sumpopulation == 17931600

	selectpopulation = query(populationquery, (select, s->(get(s,"name"), get(s,"population"))))
	for r in selectpopulation
		println("State: ", r[1], " Population: ", r[2])
	end

	# repeat the tests above, but this time move to edges instead of vertices
	sumpopulation = query(g,
				(vertices, v-> v.typelabel == "State"),
			 	(store, v->@compat Dict{String, Any}("statepopulation"=>get(v, "population"))),
			  	(incoming, e->e.typelabel == "IsCapitalOf"),
				(store, e->@compat Dict{String, Any}("capitaledge"=>e.item)),
			  	(tail, v->get(v,"population",0) > getstored(v,"statepopulation",0) * 0.5),
			  	(movetoedges, v->getstored(v,"capitaledge")), # move back to State via the stored edge
			  	head,
				(sum, v->get(v,"population"))
			 )
	@test sumpopulation == 17931600

	# sum populations, grouped by state or territory type
	groupedsum = query(g,
					   (vertices, v-> v.typelabel == "State" || v.typelabel == "Territory"),
					   (group, v-> v.typelabel),
					   (sum, v->get(v,"population")),
					   )
	# test grouped sum
	@test groupedsum["Territory"] == 624700

	# sum populations of capitals of states or territories, grouped by state or territory type
	groupedsum = query(g,
					   (vertices, v-> v.typelabel == "State" || v.typelabel == "Territory"),
					   (group, v-> v.typelabel),
					   (incoming, e->e.typelabel == "IsCapitalOf"),
					   tail,
					   (sum, v->get(v,"population"))
					   )
	@test groupedsum["Territory"] == 514578

	# multi-level group
	# sum the population of adjacent states for each state by adjacency direction
	groupedsum = query(g,
					   (vertices, v-> v.typelabel == "State" || v.typelabel == "Territory"),
					   (group, v-> get(v,"name")),
					   (outgoing, e->e.typelabel == "IsAdjacent"),
					   (group, e-> get(e,"direction","none")),
					   head,
					   (sum, v->get(v,"population"))
					   )

	# test the sum of populations of States directly West of Queensland
	@test groupedsum["Queensland"]["West"] == 1916500
end

compositequerytest()
