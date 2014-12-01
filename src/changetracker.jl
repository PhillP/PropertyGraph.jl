type ChangeTracker
	newedges::Dict{UUID.Uuid,Edge}
	newvertices::Dict{UUID.Uuid,Edge}

	changedgraphs::Dict{UUID.Uuid,Graph}
	changededges::Dict{UUID.Uuid,Edge}
	changedvertices::Dict{UUID.Uuid,Vertex}

	removededges::Dict{UUID.Uuid,Edge}
	removedvertices::Dict{UUID.Uuid,Vertex}

	ischanged::Bool
end

function ChangeTracker()
	# Constructs a Property Graph with a set of property values

	ct = new()

	ct.newedges = Dict{UUID.Uuid,Edge}()
	ct.newvertices = Dict{UUID.Uuid,Vertex}()

	ct.changededges = Dict{UUID.Uuid,Edge}()
	ct.changedvertices = Dict{UUID.Uuid,Vertex}()
	ct.changedgraphs = Dict{UUID.Uuid,Graph}()

	ct.removededges = Dict{UUID.Uuid,Edge}()
	ct.removedvertices = Dict{UUID.Uuid,Vertex}()

	ct.ischanged = false

	return ct
end

function trackadd!(ct::ChangeTracker, v::Vertex)
	ct.newvertices[v.id] = v

	ct.ischanged = true
end

function trackadd!(ct::ChangeTracker, e::Edge)
	ct.newedges[e.id] = e

	ct.ischanged = true
end

function trackchange!(ct::ChangeTracker, v::Vertex)
	ct.changedvertices[v.id] = v

	ct.ischanged = true
end

function trackchange!(ct::ChangeTracker, e::Edge)
	ct.changededges[e.id] = e

	ct.ischanged = true
end

function trackchange!(ct::ChangeTracker, g::Graph)
	ct.changedgraphs[g.id] = g

	ct.ischanged =  true
end

function trackremove(ct::ChangeTracker, v::Vertex)
	ct.removedvertices[v.id] = v

	ct.ischanged =  true
end

function trackremove(ct::ChangeTracker, e::Edge)
	ct.removededges[e.id] = e

	ct.ischanged = true
end

function clearchanges(ct::ChangeTracker, c::Container)
	ct.newedges = Dict{UUID.Uuid,Edge}()
	ct.newvertices = Dict{UUID.Uuid,Vertex}()

	ct.changededges = Dict{UUID.Uuid,Edge}()
	ct.changedvertices = Dict{UUID.Uuid,Vertex}()
	ct.changedgraphs = Dict{UUID.Uuid,Graph}()

	ct.removededges = Dict{UUID.Uuid,Edge}()
	ct.removedvertices = Dict{UUID.Uuid,Vertex}()

	ct.ischanged =  false
end
