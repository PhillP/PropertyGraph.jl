using Base.Test
using PropertyGraph
using UUID
using Compat

# run the test within a function scope to avoid interference with other tests

# define custom types required for the test
type TestCustomPersonType
	firstname::String
	lastname::String
end

type TestKnowsType
	someproperty::String
end

function graphpopulationtest()
	# create a graph
	g = Graph()

	# create a vertex and add it to the graph
	fred = add!(g, Vertex("Person", @compat Dict{String,Any}("name"=>"Fred","age"=>45)))
	# and test that it was initialised as expected
	# it should belong to the graph
	@test fred.graph == g
	# and have the property values passed in on initialisation
	@test get(fred,"name") == "Fred"
	@test get(fred,"age") == 45

	setpropertyvalue!(fred, "other", 100)
	@test get(fred,"other") == 100

	setpropertyvalues!(fred, @compat Dict{String,Any}("other"=>101,"new"=>"new value"))
	@test get(fred,"other") == 101
	@test get(fred,"new") == "new value"

	# retrieval of a property not set should return UnspecifiedValue
	@test get(fred,"otherpropertynotset") == UnspecifiedValue
	# unless a default is passed in to the get call in which case the default should be returned
	@test get(fred,"otherpropertynotset",0) == 0

	# attempting to add the same vertex again should result in error
	caughtexception = UnspecifiedValue
	try
		add!(g, fred)
	catch ex
		caughtexception = ex
	end

	@test isa(caughtexception, VertexAlreadyBelongsToSpecifiedGraphException)

	# make a new graph
	g2 = Graph()

	caughtexception = UnspecifiedValue
	try
		add!(g2, fred)
	catch ex
		caughtexception = ex
	end
	@test isa(caughtexception, VertexAlreadyBelongsToAnotherGraphException)

	# make some more vertices
	sally = add!(g, Vertex("Person", @compat Dict{String,Any}("name"=>"Sally","age"=>25)))

	johanobject = TestCustomPersonType("Johan", "Smith")
	johan = vertexforobject("Person", johanobject,  @compat Dict{String,Any}("name"=>"Johan","age"=>28))
	@test johan.containedobject == johanobject
	add!(g, johan)

	# the graph should now have 3 vertices
	@test length(g.vertices) == 3

	# create some edges
	e = Edge(fred,sally)
	e2 = Edge("knows", fred, sally, @compat Dict{String,Any}("since"=>2004))
	@test get(e2,"since") == 2004

	#including one with an associated object
	fredknowsjohanobject = TestKnowsType("SomeValue")
	e3 = edgeforobject("knows", fredknowsjohanobject, fred,johan)
	@test e3.containedobject == fredknowsjohanobject

	# add the edges to the graph
	add!(g, e)
	add!(g, e2)
	add!(g, e3)

	#the graph should now have 3 edges
	@test length(g.edges) == 3

	# test the edges are in the expected sets
	@test in(e, fred.outgoingedges)
	@test in(e2, fred.outgoingedges)
	@test in(e3, fred.outgoingedges)
	@test length(fred.outgoingedges) == 3

	@test in(e, sally.incomingedges)
	@test in(e2, sally.incomingedges)
	@test length(sally.incomingedges) == 2

	@test in(e3, johan.incomingedges)
	@test length(johan.incomingedges) == 1

	# test adding an edge already in the graph
	# this should result in exception
	caughtexception = UnspecifiedValue
	try
		add!(g, e)
	catch ex
		caughtexception = ex
	end
	@test isa(caughtexception, EdgeAlreadyBelongsToSpecifiedGraphException)

	# test adding an edge to another graph
	# this should result in exception
	caughtexception = UnspecifiedValue
	try
		add!(g2, e)
	catch ex
		caughtexception = ex
	end
	@test isa(caughtexception, EdgeAlreadyBelongsToAnotherGraphException)

	# create another vertex but don't add it to the graph
	unaddedVertex = Vertex("Person")

	# create another edge involving the new vertex as tail
	e4 = Edge(unaddedVertex,sally)

	# attempt adding the edge to the graph involving a vertex with tail not in the graph
	caughtexception = UnspecifiedValue
	try
		add!(g, e4)
	catch ex
		caughtexception = ex
	end

	@test isa(caughtexception, EdgeTailDoesNotBelongToGraphException)

	# create another edge involving the new vertex as head
	e5 = Edge(sally, unaddedVertex)

	# attempt adding the edge to the graph involving a vertex with head not in the graph
	caughtexception = UnspecifiedValue
	try
		add!(g, e5)
	catch ex
		caughtexception = ex
	end
	@test isa(caughtexception, EdgeHeadDoesNotBelongToGraphException)
end
graphpopulationtest()

