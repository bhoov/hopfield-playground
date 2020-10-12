### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ b105d9c2-0a79-11eb-2f6f-4b12f9498f89
md"""
# Playing with Continuous Modern Hopfield Networks

Math and inspiration taken from the [Hopfield Networks is All You Need Blog](https://ml-jku.github.io/hopfield-layers/)
"""

# ╔═╡ c2178776-0a79-11eb-00ad-6dc98d15955e
md"""
### Creating the environment
"""

# ╔═╡ 70d5be76-0a5d-11eb-2626-6799926deaeb
begin
    import Pkg
    Pkg.activate(mktempdir())
end

# ╔═╡ 79ed37bc-0a5d-11eb-2033-21326bb765ae
begin
    Pkg.add([
            "Images",
            "ImageMagick",
            "Compose",
            "ImageFiltering",
            "TestImages",
            "Statistics",
            "PlutoUI",
            "BenchmarkTools",
			"MLDatasets",
			"Colors",
			"StatsBase",
			"DelimitedFiles",
			"JSON2",
			"Tables"
            ])
	
	using Tables
	using JSON2
	using DelimitedFiles
    using Images
	using StatsBase
    using PlutoUI
	using MLDatasets
end

# ╔═╡ d2635856-0a79-11eb-3cb7-e57a008425b5
md"""
### Load data, create helper functions
"""

# ╔═╡ df4e3e08-0a5d-11eb-331c-59c2cd60bb4a
begin
	train_x, train_y = MNIST.traindata();
	train_x = Gray.(permutedims(train_x, (2,1,3)))
	x, y, n_examples = size(train_x)
end

# ╔═╡ f08135ee-0a77-11eb-2caa-ab85b93ddb38
begin
	
	"""Convert single MNIST image into flat memory"""
	function flattenImg(img::Array)
		return reshape(img, x*y)
	end
	
	"""View a memory as an image"""
	function viewMem(arr::Array)
		reshape(arr, x, y)
	end
	
	"""Obscure an array for an incomplete pattern"""
	function obscureMem(arr::Array, fracAffected=0.9)
		newState = copy(arr)
		n = length(arr)
		nAffected = floor(Int, fracAffected * n)
		affectedIdxs = sample(1:n, nAffected, replace=false)
		newState[affectedIdxs] .= 0
		return newState
	end
	
	softmax(x) = exp.(x) ./ sum(exp.(x))
	function updateMem(ξ, X, β)
		return X * softmax(β*transpose(X)*ξ)
	end
end

# ╔═╡ e37dcd7e-0a79-11eb-1273-2f35d70a42a1
md"""
## Interaction

### Finding a Memory

Change the seed index to select any memory the model has seen.

Change the total number of memories stored by the model (from 1 -> reasonable max number). Will perform slower at higher numbers

Change the amount to obscure the state vector.

Change the inverse temperature parameter β


"""

# ╔═╡ ed96a526-0a68-11eb-0dd8-33787eab6779
NumberOfMemories = @bind nMemories Slider(5:100:30000, show_value=true, default=30)

# ╔═╡ 5758e8e0-0a6a-11eb-203f-4578e79a8ea6
begin
	rawMemories = Gray.(train_x[:,:,1:nMemories]);
	X = reshape(rawMemories, x*y, nMemories);
	md"""Create memory matrix $X$"""
end

# ╔═╡ b2ff9d5a-0a6d-11eb-0803-792ae4dd0997
PercentObscured = @bind pctAffected Slider(0:0.02:1.0, default=0.5, show_value=true)

# ╔═╡ 7de67790-0a6f-11eb-2b9f-91ec6a0035e9
Beta = @bind β Slider(0.001:0.001:2, show_value=true)

# ╔═╡ 82f2fbe0-0a7a-11eb-2faf-5730af229577
md"""
Seed displayed on the left. Retrieved image on the right
"""

# ╔═╡ 9d4ffdc6-0a7a-11eb-3e52-4f7c39e6f8d2
md"""
### What if the memory was never stored?

Look what happens if we change the seed index to only include memories not seen by the model
"""

# ╔═╡ dea5fafa-0a7a-11eb-2db7-a16b04aa4b65
ShowUnseen = @bind showUnseen CheckBox(default=false)

# ╔═╡ 5fdf7c86-0a7b-11eb-3cd2-fbc1983423d2
begin
	start = showUnseen ? nMemories + 1 : 1
	stop = showUnseen ? n_examples : nMemories
	SeedMemoryIndex = @bind seedIdx Slider(start:stop, show_value=true, default=start)
	md"""SeedMemoryIndex = $(SeedMemoryIndex)"""
end

# ╔═╡ ffa9b626-0a6e-11eb-0d32-538c15bc83a4
begin
	ξ = obscureMem(flattenImg(Gray.(train_x[:,:,seedIdx])), pctAffected)
	[viewMem(ξ) viewMem(updateMem(ξ, X, β))]
end

# ╔═╡ a74409a2-0a7b-11eb-2b15-b51ae49b13fb
md"""
It looks like the model develops a really incomplete understanding of the pattern even if there are patterns that are very similar
"""

# ╔═╡ 414d5b8e-0a77-11eb-08e3-95585ff4ae9d
md"""
### TODO:

- [ ] Increasing obscurity does not shuffle which pixels are obscured
- [ ] See if you can use a more complicated interactive javascript function from pluto
"""

# ╔═╡ 9e592eec-0c2b-11eb-197a-abf462227e23
md"""
## Implementing a more complicated JS function
"""

# ╔═╡ 063acf66-0c81-11eb-3244-dd15e40efcd1
md"""
### Understanding how to incorporate vue into a Notebook

	1. Need a string defining the HTML template of the Vue instance
	2. Include scripts to import Vue
	3. Have a script tag that instantiates the vue object on the custom Julia data
	4. customize vue style tags

But where do I define the complicated Vue object? I don't want to just develop it in a string...
"""

# ╔═╡ 42fc0260-0c2e-11eb-0668-610a6e1d338a
function data_table(table)

	return HTML("""
		<link href="https://cdn.jsdelivr.net/npm/@mdi/font@5.x/css/materialdesignicons.min.css" rel="stylesheet">
		<link href="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.min.css" rel="stylesheet">

	  <div id="app42">
		<v-app>
		  <v-data-table
		  :headers="headers"
		  :items="states"
		></v-data-table>
		</v-app>
	  </div>
		
		
	  <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
	  <script src="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.js"></script>


	<script>
		new Vue({
		  el: '#app42',
		  vuetify: new Vuetify(),
		  data () {
				return $table
			}
		})
	</script>
	<style>
		.v-application--wrap {
			min-height: 10Evh;
		}
		.v-data-footer__select {
			display: none;
		}
	</style>
	""")
end

# ╔═╡ e07a6886-0c2e-11eb-087b-5bc1127ef992
begin
	states = readdlm(raw"./testdata.csv", ',', header=true)

	states_dict = Dict(
		"headers" => [Dict("text" => "Name", "value" => "name"), Dict("text" => "Abbreviation", "value" => "abbrev"), Dict("text" => "FIPS", "value" => "fips")],
		"states" => [Dict("name" => states[1][i,1], "abbrev" => states[1][i,2], "fips" => states[1][i,3]) for i in 1:size(states[1],1)]
)
end

# ╔═╡ 009ebc22-0c8e-11eb-0545-b15f16c95de4
data_table(JSON2.write(states_dict))

# ╔═╡ 7a53290e-0c8e-11eb-08dd-8bda658ea915
md"""
## My own code
"""

# ╔═╡ 7f863ffe-0c8e-11eb-3e7a-59f8a4cceda2
HTML("""
	<div id="attention-div"></div>
	
	<script>
	function randomArr(length) {
	  return Array.from(Array(length)).map((x) => Math.random());
	}

	let tokens = ["Hello", "world", "."];
	let tokensTarget = ["What", "is", "the", "meaning", "of", "life", "?"]; // If not provided, defaults to `tokens`
	let attentions = tokens.map((t) => randomArr(tokensTarget.length)); // Matrix of shape (nTokens, nTokensTarget)


	var Attention = await require("svelte-attention-vis")
	console.log("ME: ", attentions)
	let app = new Attention({
		target: document.querySelector("#attention-div"),
		props: {
		  tokens,
		tokensTarget,
		  attentions
		}
    });
	
	</script>
	
	""")

# ╔═╡ 602d3c2e-0c94-11eb-0b38-7f45df489062
md"""
So it looks like the code runs, but nothing is showing up... I can't tell if that's a problem with the attention vis code though since that package was never checked. 

The downsides:

	- This approach requires developing the visualization in a separate repository and then uploading to NPM... I can't figure out how to import JS code files into the notebook
"""

# ╔═╡ bb06d9e8-0c91-11eb-2372-1fa86d091ee1
HTML("""
	<div id="gross-div"></div>
	
	<script>
		const d3 = await require("d3")
	const markup = ` Wow! I can actually load D3 and use it inside pluto! That means I should be able to easily bind any JSONified Julia object to a custom visualization as I need. Nice! `
		d3.select("#gross-div").text(markup)
	</script>
	""")

# ╔═╡ 578d332a-0c92-11eb-21b7-d12f9bd60c18
HTML("""
	
	<div id="mycloud"></div>
	
	<script>
	const d3 = await require("d3")
	const cloud = await require("d3-cloud")
	
	var layout = cloud()
		.size([500, 500])
		.words(["This", "is", "me", "trying", "out", "this", "word", "cloud", "thing", 
		  "Hello", "world", "normally", "you", "want", "more", "words",
		  "than", "this"].map(function(d) {
		  return {text: d, size: 10 + Math.random() * 90};
		}))
		.padding(5)
		.rotate(function() { return ~~(Math.random() * 2) * 90; })
		.font("Impact")
		.fontSize(function(d) { return d.size; })
		.on("end", draw);

	layout.start();

	function draw(words) {
	  d3.select("#mycloud").append("svg")
		  .attr("width", layout.size()[0])
		  .attr("height", layout.size()[1])
		.append("g")
		  .attr("transform", "translate(" + layout.size()[0] / 2 + "," + layout.size()[1] / 2 + ")")
		.selectAll("text")
		  .data(words)
		.enter().append("text")
		  .style("font-size", function(d) { return d.size + "px"; })
		  .style("font-family", "Impact")
		  .attr("text-anchor", "middle")
		  .attr("transform", function(d) {
			return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
		  })
		  .text(function(d) { return d.text; });
	}
	</script>
	""")

# ╔═╡ Cell order:
# ╟─b105d9c2-0a79-11eb-2f6f-4b12f9498f89
# ╟─c2178776-0a79-11eb-00ad-6dc98d15955e
# ╠═70d5be76-0a5d-11eb-2626-6799926deaeb
# ╠═79ed37bc-0a5d-11eb-2033-21326bb765ae
# ╟─d2635856-0a79-11eb-3cb7-e57a008425b5
# ╠═df4e3e08-0a5d-11eb-331c-59c2cd60bb4a
# ╠═f08135ee-0a77-11eb-2caa-ab85b93ddb38
# ╠═5758e8e0-0a6a-11eb-203f-4578e79a8ea6
# ╟─e37dcd7e-0a79-11eb-1273-2f35d70a42a1
# ╟─5fdf7c86-0a7b-11eb-3cd2-fbc1983423d2
# ╟─ed96a526-0a68-11eb-0dd8-33787eab6779
# ╟─b2ff9d5a-0a6d-11eb-0803-792ae4dd0997
# ╟─7de67790-0a6f-11eb-2b9f-91ec6a0035e9
# ╟─82f2fbe0-0a7a-11eb-2faf-5730af229577
# ╟─ffa9b626-0a6e-11eb-0d32-538c15bc83a4
# ╟─9d4ffdc6-0a7a-11eb-3e52-4f7c39e6f8d2
# ╟─dea5fafa-0a7a-11eb-2db7-a16b04aa4b65
# ╟─a74409a2-0a7b-11eb-2b15-b51ae49b13fb
# ╟─414d5b8e-0a77-11eb-08e3-95585ff4ae9d
# ╟─9e592eec-0c2b-11eb-197a-abf462227e23
# ╟─063acf66-0c81-11eb-3244-dd15e40efcd1
# ╠═42fc0260-0c2e-11eb-0668-610a6e1d338a
# ╠═e07a6886-0c2e-11eb-087b-5bc1127ef992
# ╠═009ebc22-0c8e-11eb-0545-b15f16c95de4
# ╟─7a53290e-0c8e-11eb-08dd-8bda658ea915
# ╠═7f863ffe-0c8e-11eb-3e7a-59f8a4cceda2
# ╠═602d3c2e-0c94-11eb-0b38-7f45df489062
# ╠═bb06d9e8-0c91-11eb-2372-1fa86d091ee1
# ╠═578d332a-0c92-11eb-21b7-d12f9bd60c18
