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
			"StatsBase"
            ])
	
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

Change the total number of memories stored by the model (from 1 -> number of examples in MNIST). Will perform slower at higher numbers

Change the amount to obscure the state vector.

Change the inverse temperature parameter β


"""

# ╔═╡ ed96a526-0a68-11eb-0dd8-33787eab6779
NumberOfMemories = @bind nMemories Slider(5:5:5000, show_value=true, default=30)

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

# ╔═╡ 414d5b8e-0a77-11eb-08e3-95585ff4ae9d
md"""
Still to do:

- [ ] Increasing obscurity does not shuffle which pixels are obscured
- [ ] Put into Repo
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
# ╠═5fdf7c86-0a7b-11eb-3cd2-fbc1983423d2
# ╟─ed96a526-0a68-11eb-0dd8-33787eab6779
# ╟─b2ff9d5a-0a6d-11eb-0803-792ae4dd0997
# ╟─7de67790-0a6f-11eb-2b9f-91ec6a0035e9
# ╟─82f2fbe0-0a7a-11eb-2faf-5730af229577
# ╠═ffa9b626-0a6e-11eb-0d32-538c15bc83a4
# ╟─414d5b8e-0a77-11eb-08e3-95585ff4ae9d
# ╟─9d4ffdc6-0a7a-11eb-3e52-4f7c39e6f8d2
# ╟─dea5fafa-0a7a-11eb-2db7-a16b04aa4b65
# ╟─a74409a2-0a7b-11eb-2b15-b51ae49b13fb
