type CompositeQueryResultItem
	# A result item part of an overall set of result of a CompositeQuery
	id::UUID.Uuid
	typelabel::String
	item::Container
	containedobject::Any
	hassource::Bool
	sourceresultitem::CompositeQueryResultItem
	storedvalues::Dict{String, Any}
	isnew::Bool

	function CompositeQueryResultItem(newitem::Container, source::CompositeQueryResultItem)
		# Constructs a ResultItem given an item (Vertex or Edge) and a previous result
		r = new()

		r.item = newitem
		r.id = newitem.id
		r.typelabel = newitem.typelabel
		if isdefined(newitem,:containedobject)
			r.containedobject = newitem.containedobject
		end
		r.hassource = true
		r.sourceresultitem = source
		r.storedvalues = copy(source.storedvalues)
		r.isnew = true

		return r
	end

	function CompositeQueryResultItem(newitem::Container)
		# Constructs a ResultItem given a container (Vertex or Edge)
		r = new()

		r.item = newitem
		r.id = newitem.id
		r.typelabel = newitem.typelabel
		r.containedobject = UnspecifiedValue
		r.hassource = false
		r.storedvalues = Dict{String,Any}()
		r.isnew = true

		return r
	end
end

function get(resultitem::CompositeQueryResultItem, name::String, default::Any=UnspecifiedValue)
	# get the value of a specified property, returning a default value if there is no other property value associated
	return get(resultitem.item,name,default)
end

function getstored(resultitem::CompositeQueryResultItem, name::String, default::Any=UnspecifiedValue)
	# retrieve a stored value
	return Base.get(resultitem.storedvalues,name,default)
end

function store(resultitem::CompositeQueryResultItem, name::String, value::Any)
	# store a value on the as part of the result item
	resultitem.storedvalues[name] = value
end
