function buildstatetestgraph()
	g = Graph()

	australia = add!(g, Vertex("Country", @compat Dict{String,Any}("name"=>"Australia","population"=>23235800)))

	northernterritory = add!(g, Vertex("Territory", @compat Dict{String,Any}("name"=>"Northern Territory","population"=>241800)))
	tasmania = add!(g, Vertex("State", @compat Dict{String,Any}("name"=>"Tasmania","population"=>513400)))
	westernaustralia = add!(g, Vertex("State", @compat Dict{String,Any}("name"=>"Western Australia","population"=>2535700)))
	queensland = add!(g, Vertex("State", @compat Dict{String,Any}("name"=>"Queensland","population"=>4676400)))
	southaustralia = add!(g, Vertex("State", @compat Dict{String,Any}("name"=>"South Australia","population"=>1674700)))
	newsouthwales = add!(g, Vertex("State", @compat Dict{String,Any}("name"=>"New South Wales","population"=>7439200)))
	victoria = add!(g, Vertex("State", @compat Dict{String,Any}("name"=>"Victoria","population"=>5768600)))
	australiancapitalterritory = add!(g, Vertex("Territory", @compat Dict{String,Any}("name"=>"Australian Capital Territory","population"=>382900)))

	add!(g, Edge("IsIn", northernterritory, australia))
	add!(g, Edge("IsIn", tasmania, australia))
	add!(g, Edge("IsIn", westernaustralia, australia))
	add!(g, Edge("IsIn", queensland, australia))
	add!(g, Edge("IsIn", southaustralia, australia))
	add!(g, Edge("IsIn", newsouthwales, australia))
	add!(g, Edge("IsIn", victoria, australia))
	add!(g, Edge("IsIn", australiancapitalterritory, australia))

	add!(g, Edge("IsAdjacent", northernterritory, westernaustralia, @compat Dict{String,Any}("direction"=>"West")))
	add!(g, Edge("IsAdjacent", northernterritory, southaustralia, @compat Dict{String,Any}("direction"=>"South")))
	add!(g, Edge("IsAdjacent", northernterritory, queensland, @compat Dict{String,Any}("direction"=>"East")))

	add!(g, Edge("IsAdjacent", westernaustralia, northernterritory, @compat Dict{String,Any}("direction"=>"East")))
	add!(g, Edge("IsAdjacent", westernaustralia, southaustralia, @compat Dict{String,Any}("direction"=>"East")))

	add!(g, Edge("IsAdjacent", southaustralia, northernterritory, @compat Dict{String,Any}("direction"=>"North")))
	add!(g, Edge("IsAdjacent", southaustralia, westernaustralia, @compat Dict{String,Any}("direction"=>"West")))
	add!(g, Edge("IsAdjacent", southaustralia, victoria, @compat Dict{String,Any}("direction"=>"East")))
	add!(g, Edge("IsAdjacent", southaustralia, newsouthwales, @compat Dict{String,Any}("direction"=>"East")))
	add!(g, Edge("IsAdjacent", southaustralia, queensland, @compat Dict{String,Any}("direction"=>"East")))

	add!(g, Edge("IsAdjacent", newsouthwales, victoria, @compat Dict{String,Any}("direction"=>"South")))
	add!(g, Edge("IsAdjacent", newsouthwales, australiancapitalterritory))
	add!(g, Edge("IsAdjacent", newsouthwales, queensland, @compat Dict{String,Any}("direction"=>"North")))
	add!(g, Edge("IsAdjacent", newsouthwales, southaustralia, @compat Dict{String,Any}("direction"=>"West")))

	add!(g, Edge("IsAdjacent", victoria, newsouthwales, @compat Dict{String,Any}("direction"=>"North")))
	add!(g, Edge("IsAdjacent", victoria, southaustralia, @compat Dict{String,Any}("direction"=>"West")))

	add!(g, Edge("IsAdjacent", queensland, newsouthwales, @compat Dict{String,Any}("direction"=>"South")))
	add!(g, Edge("IsAdjacent", queensland, northernterritory, @compat Dict{String,Any}("direction"=>"West")))
	add!(g, Edge("IsAdjacent", queensland, southaustralia, @compat Dict{String,Any}("direction"=>"West")))

	sydney = add!(g, Vertex("City", @compat Dict{String,Any}("name"=>"Sydney", "population"=>4667283)))
	perth = add!(g, Vertex("City", @compat Dict{String,Any}("name"=>"Perth","population"=>1897548)))
	brisbane = add!(g, Vertex("City", @compat Dict{String,Any}("name"=>"Brisbane", "population"=>2189878)))
	hobart = add!(g, Vertex("City", @compat Dict{String,Any}("name"=>"Hobart", "population"=>282099)))
	canberra = add!(g, Vertex("City", @compat Dict{String,Any}("name"=>"Canberra", "population"=>382900)))
	darwin = add!(g, Vertex("City", @compat Dict{String,Any}("name"=>"Darwin", "population"=>131678)))
	melbourne = add!(g, Vertex("City", @compat Dict{String,Any}("name"=>"Melbourne","population"=>4246345)))
	adelaide = add!(g, Vertex("City", @compat Dict{String,Any}("name"=>"Adelaide","population"=>1277174)))

	add!(g, Edge("IsCapitalOf", sydney, newsouthwales))
	add!(g, Edge("IsCapitalOf", perth, westernaustralia))
	add!(g, Edge("IsCapitalOf", brisbane, queensland))
	add!(g, Edge("IsCapitalOf", hobart, tasmania))
	add!(g, Edge("IsCapitalOf", darwin, northernterritory))
	add!(g, Edge("IsCapitalOf", melbourne, victoria))
	add!(g, Edge("IsCapitalOf", canberra, australiancapitalterritory))
	add!(g, Edge("IsCapitalOf", canberra, australia))
	add!(g, Edge("IsCapitalOf", adelaide, southaustralia))

	return g
end
