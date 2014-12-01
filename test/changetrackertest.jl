using Base.Test
using PropertyGraph
using UUID
using Compat

function graphpopulationtest()
	# create a graph
	g = Graph()
	g.tracker = ChangeTracker()

	@test g.tracker.ischanged == false

	nodea = add!(g, Vertex("Node", @compat Dict{String,Any}("name"=>"a", "val"=>50)))
	nodeb = add!(g, Vertex("Node", @compat Dict{String,Any}("name"=>"b", "val"=>51)))
	nodec = add!(g, Vertex("Node", @compat Dict{String,Any}("name"=>"c", "val"=>60)))
	noded = add!(g, Vertex("Node", @compat Dict{String,Any}("name"=>"d", "val"=>70)))

	edgeab = add!(g, Edge("NodeToNode", nodea, nodeb, @compat Dict{String,Any}("val"=>100)))
	edgeac = add!(g, Edge("NodeToNode", nodea, nodec, @compat Dict{String,Any}("val"=>160)))

	@test g.tracker.ischanged == true
	@test haskey(g.tracker.newvertices, nodea.id)
	@test haskey(g.tracker.newvertices, nodeb.id)
	@test haskey(g.tracker.newvertices, nodec.id)
	@test haskey(g.tracker.newvertices, noded.id)
	@test haskey(g.tracker.newedges, edgeab.id)
	@test haskey(g.tracker.newedges, edgeac.id)

	@test length(g.tracker.newvertices) == 4
	@test length(g.tracker.newedges) == 2
	@test length(g.tracker.changededges) == 0
	@test length(g.tracker.changedvertices) == 0
	@test length(g.tracker.changedgraphs) == 0
	@test length(g.tracker.deletededges) == 0
	@test length(g.tracker.deletedvertices) == 0

	setpropertyvalues!(nodea, @compat Dict{String,Any}("val"=>150,"new"=>"new value"))
	setpropertyvalue!(edgeab, "val", 200)

	@test haskey(g.tracker.changedvertices, nodea.id)
	@test haskey(g.tracker.changededges, edgeab.id)
	@test length(g.tracker.newvertices) == 4
	@test length(g.tracker.newedges) == 2
	@test length(g.tracker.changededges) == 1
	@test length(g.tracker.changedvertices) == 1
	@test length(g.tracker.changedgraphs) == 0
	@test length(g.tracker.deletededges) == 0
	@test length(g.tracker.deletedvertices) == 0

	clearchanges(g.tracker)

	@test g.tracker.ischanged == false
	@test length(g.tracker.newvertices) == 0
	@test length(g.tracker.newedges) == 0
	@test length(g.tracker.changededges) == 0
	@test length(g.tracker.changedvertices) == 0
	@test length(g.tracker.changedgraphs) == 0
	@test length(g.tracker.deletededges) == 0
	@test length(g.tracker.deletedvertices) == 0

	remove!(g, noded)

	@test g.tracker.ischanged == true
	@test haskey(g.tracker.deletedvertices, noded.id)
	@test length(g.tracker.newvertices) == 0
	@test length(g.tracker.newedges) == 0
	@test length(g.tracker.changededges) == 0
	@test length(g.tracker.changedvertices) == 0
	@test length(g.tracker.changedgraphs) == 0
	@test length(g.tracker.deletededges) == 0
	@test length(g.tracker.deletedvertices) == 1

	remove!(g, edgeab)

	@test haskey(g.tracker.deletededges, edgeab.id)
	@test length(g.tracker.newvertices) == 0
	@test length(g.tracker.newedges) == 0
	@test length(g.tracker.changededges) == 0
	@test length(g.tracker.changedvertices) == 0
	@test length(g.tracker.changedgraphs) == 0
	@test length(g.tracker.deletededges) == 1
	@test length(g.tracker.deletedvertices) == 1

	remove!(g, nodec) # removing a node will auto-remove its edges

	@test haskey(g.tracker.deletedvertices, nodec.id)
	@test haskey(g.tracker.deletededges, edgeac.id)
	@test length(g.tracker.newvertices) == 0
	@test length(g.tracker.newedges) == 0
	@test length(g.tracker.changededges) == 0
	@test length(g.tracker.changedvertices) == 0
	@test length(g.tracker.changedgraphs) == 0
	@test length(g.tracker.deletededges) == 2
	@test length(g.tracker.deletedvertices) == 2

	clearchanges(g.tracker)
end
