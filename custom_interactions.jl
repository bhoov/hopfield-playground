### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ 11eca9ec-29aa-11eb-2083-e78ef83d2441
begin
    import Pkg
    Pkg.activate(mktempdir())
	Pkg.add([
		"DelimitedFiles",
		"JSON2",
		"Tables",
		])
	
	using Tables
	using JSON2
	using DelimitedFiles
end

# ╔═╡ d7f6f404-29a9-11eb-2f50-25bb7615cb2b
md"""
# Implementing Custom JS Interaction
"""

# ╔═╡ f3d072fe-29a9-11eb-3c33-23783f656d58
md"""
## Using Vue from Online example

Discussion [here](https://discourse.julialang.org/t/interactive-data-table-in-pluto-jl-via-a-silly-hack/44678)
"""

# ╔═╡ 6bcd3648-29aa-11eb-063f-f36890f95fd2
md"""
We use a Julia function that takes a JSON data structure and spits out an HTML string, formatted with links to the CDNs of the tools we use, and with a script tag that mounts our visualization to a DOM element
"""

# ╔═╡ f70b2770-29a9-11eb-0ebe-cf52a8508ebe
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

# ╔═╡ 9faa7372-29aa-11eb-26c4-eb0b639a0854
md"""
The JSON must be formatted in a particular way for the Vue component to read it
"""

# ╔═╡ fb301d4c-29a9-11eb-052e-4122b6c51048
begin
	states = readdlm(raw"./testdata.csv", ',', header=true)

	states_dict = Dict(
		"headers" => [Dict("text" => "Name", "value" => "name"), Dict("text" => "Abbreviation", "value" => "abbrev"), Dict("text" => "FIPS", "value" => "fips")],
		"states" => [Dict("name" => states[1][i,1], "abbrev" => states[1][i,2], "fips" => states[1][i,3]) for i in 1:size(states[1],1)]
)
end

# ╔═╡ b59c12b2-29aa-11eb-16a7-558ea3b0c19f
md"""
Shown below:
"""

# ╔═╡ ff3ad9fe-29a9-11eb-3a7e-c1668043d005
data_table(JSON2.write(states_dict))

# ╔═╡ 5154d6ee-29ab-11eb-282a-01b1c545faa1
md"""
## Using D3 Word Cloud with `require`

We can use D3 from CDN and d3 plugins as below
"""

# ╔═╡ 742eeb7a-29ab-11eb-2952-e19d2d889acd
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

# ╔═╡ 16f72b28-29ab-11eb-31c3-f77b5950bf24
md"""
## Using my own NPM Package

Theoretically, using a custom package that we push to NPM and pull from CDN should also work. Here is an example of using a component I have pushed to npm. For some reason, it does not display (though the component could be broken).
"""

# ╔═╡ 1169aae6-29ab-11eb-2a6d-35e7f4293a4b
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

# ╔═╡ c1252614-29aa-11eb-12a6-e904fbc47d38
md"""
## Using a local JS file

Unfortunately, we sometimes want to build in interaction that is not available in a prepackaged component. Because JS interactions can get complicated, we want to develop a special component in our project and be able to bind to it within this notebook

Within this project folder, there is a file called `components/sample.js` which exports a function that takes a div with ID `test-div` and sets the text content to `SAMPLE JS HAS RUN`. We want to import this script, manipulate the DOM, and ideally expose an 'input' event that Julia can bind to.

This problem remains unsolved. However, the best way to serve this file is to have Julia fetch the text content and fill in custom HTML with it
"""

# ╔═╡ e73a2f1a-29ab-11eb-19b1-171f25fd8b3c
begin
	file = open("components/sample.js")
	fstuff = read(file, String)
	close(file)
end 

# ╔═╡ 46497056-29ac-11eb-320e-75e1993b8ad2
HTML("""
	<div id="test-div">Sample js has not run...</div>
	<script type="module">
	$fstuff
	
	app("#test-div")
	</script>
	""")

# ╔═╡ aa8c9534-29ac-11eb-1ffd-95d029dae072
md"""
I still don't understand how to work with `<script type="module"></script>` which is supposed to handle importing and exporting of components within the browser. For some reason it seems broken...
"""

# ╔═╡ Cell order:
# ╠═d7f6f404-29a9-11eb-2f50-25bb7615cb2b
# ╟─11eca9ec-29aa-11eb-2083-e78ef83d2441
# ╠═f3d072fe-29a9-11eb-3c33-23783f656d58
# ╟─6bcd3648-29aa-11eb-063f-f36890f95fd2
# ╠═f70b2770-29a9-11eb-0ebe-cf52a8508ebe
# ╟─9faa7372-29aa-11eb-26c4-eb0b639a0854
# ╠═fb301d4c-29a9-11eb-052e-4122b6c51048
# ╟─b59c12b2-29aa-11eb-16a7-558ea3b0c19f
# ╟─ff3ad9fe-29a9-11eb-3a7e-c1668043d005
# ╠═5154d6ee-29ab-11eb-282a-01b1c545faa1
# ╠═742eeb7a-29ab-11eb-2952-e19d2d889acd
# ╠═16f72b28-29ab-11eb-31c3-f77b5950bf24
# ╠═1169aae6-29ab-11eb-2a6d-35e7f4293a4b
# ╟─c1252614-29aa-11eb-12a6-e904fbc47d38
# ╠═e73a2f1a-29ab-11eb-19b1-171f25fd8b3c
# ╠═46497056-29ac-11eb-320e-75e1993b8ad2
# ╟─aa8c9534-29ac-11eb-1ffd-95d029dae072
