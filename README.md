# Interactively Exploring Hopfield Network Behavior 

Math and inspiration taken from the [Hopfield Networks is All You Need Blog](https://ml-jku.github.io/hopfield-layers/)

## Getting Started
To use this interactive notebook, you'll have to use [Julia](https://julialang.org/downloads/). Thankfully, this language is rapidly growing in popularity and is designed to be simple to code in for scientists and mathematicians.

A 6 min video on how to do this [here](https://www.youtube.com/watch?v=OOjKEgbt8AI)

1. Download the [latest version of Julia](https://julialang.org/downloads/). Follow the default instructions for MacOS
2. Open the newly installed `julia-1.5.x`. This should open a terminal with a julia instance.
3. Install [Pluto.jl](https://github.com/fonsp/Pluto.jl). Follow the instructions on that repo, or below:
    - Press the `[` key in the terminal. You are now in the package environment.
    - Type `add Pluto`. This will take a moment to download.
    - Backspace out of the package manager
    - `import Pluto`
    - `Pluto.run()`

This will open a Jupyter-like interface that will allow you to browse to `notebook.jl`.

Unlike python, Julia has a longer start up time. This is because the code you write is immediately compiled. This also allows the code to run at near C-speeds and enables Pluto to have the interactive speeds you will shortly see.

The environment is self contained in the notebook and will take a while to run the first time.