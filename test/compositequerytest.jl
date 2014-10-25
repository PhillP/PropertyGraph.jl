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
end

compositequerytest()
