include("../src/LightGraphs.jl")
pd = pwd()
using LightGraphs
# pd = joinpath(Pkg.dir(), string(module_name(LightGraphs)))

# This file generated the Markdown documentation files.

# The @file macro generates the documentation for a particular file
# where the {{method1, methods2}} includes the documentation for each method
# via the `buildwriter` function.

# Currently this prints the methodtable followed by the docstring.

macro file(args...) buildfile(args...) end

buildfile(t, s::AbstractString) = buildfile(t, Expr(:string, s))


buildfile(target, source::Symbol) = quote
    open(joinpath(dirname(@__FILE__), $(esc(target))), "w") do file
        println(" - '$($(esc(target)))'")
        println(file, "<!-- AUTOGENERATED. See 'doc/build.jl' for source. -->")
        println(file, $(esc(source)))
    end
end

buildfile(target, source::Expr) = quote
    open(joinpath(dirname(@__FILE__), $(esc(target))), "w") do file
        println(" - '$($(esc(target)))'")
        println(file, "<!-- AUTOGENERATED. See 'doc/build.jl' for source. -->")
        $(Expr(:block, [buildwriter(arg) for arg in source.args]...))
    end
end

buildwriter(s::Symbol) = :(print(file, $(esc(s))))

buildwriter(ex::Expr) = :(print(file, $(esc(ex))))

buildwriter(t::AbstractString) = Expr(:block,
    [buildwriter(p, iseven(n)) for (n, p) in enumerate(split(t, r"^{{|\n{{|}}\s*(\n|$)"))]...
)


buildwriter(part, isdef) = isdef ?
    begin
        parts = Expr(:vect, [:(($(parse(p))), @doc($(parse(p)))) for p in split(part, r"\s*,\s*")]...)
        quote
            for (f, docstring) in $(esc(parts))
                if isa(f, Function)
                    println(file, "### ", first(methods(f)).func.code.name)
                    docs = getlgdoc(docstring)
                    printsignature = true
                    if isa(docs[1][1], Markdown.Code)
                        c = docs[1][1].code
                        s = split(string(f),".")
                        if ((length(s) == 1  &&  startswith(c, s[1]))
                           || (length(s) > 1 && s[1] == "LightGraphs" && startswith(c, s[2])))
                            printsignature = false  # the signature is in the docstring
                            docs[1][1].language = "julia"    # set language to julia
                        end
                    end
                    printsignature && md_methodtable(file, f)
                    writemime(file, "text/plain", docs[1])
                    if length(docs) > 1
                        for d in docs[2:end]
                            println(file)
                            !printsignature && (d[1].language="julia")
                            writemime(file, "text/plain", d)
                        end
                    end
                else
                    writemime(file, "text/plain", docstring)
                end
                println(file)
            end
        end
    end :
    :(print(file, $(esc(part))))

getlgdoc(docstring) = docstring.content[find(c->c.meta[:module] == LightGraphs, docstring.content)]

function md_methodtable(io, f)
    println(io, "```julia")
    for m in methods(f)
        md_method(io, m)
    end
    println(io, "```")
end

function md_method(io, m)
    # We only print methods with are defined in the parent (project) directory
    if !(startswith(string(m.func.code.file), pd))
        return
    end
    print(io, m.func.code.name)
    tv, decls, file, line = Base.arg_decl_parts(m)
    if !isempty(tv)
        Base.show_delim_array(io, tv, '{', ',', '}', false)
    end
    print(io, "(")
    print_joined(io, [isempty(d[2]) ? "$(d[1])" : "$(d[1])::$(d[2])" for d in decls],
                 ", ", ", ")
    print(io, ")")
    println(io)
end

readme = open("README.md") do f
            readall(f)
        end

@file "index.md" readme

@file "basicmeasures.md" """
# Basic Functions

The following basic measures have been implemented for `Graph` and `DiGraph`
types:

## Vertices and Edges

{{vertices, edges, is_directed, nv, ne, has_edge, has_vertex, in_edges, out_edges, src, dst, reverse}}

## Neighbors and Degree

{{degree, indegree, outdegree, Δ, δ, Δout, δout, δin, Δin, degree_histogram, density, neighbors, in_neighbors, all_neighbors, common_neighbors}}
"""

@file "centrality.md" """
# Centrality Measures

[Centrality measures](https://en.wikipedia.org/wiki/Centrality) describe the
importance of a vertex to the rest of the graph using some set of criteria.
Centrality measures implemented in *LightGraphs.jl* include the following:

{{degree_centrality, indegree_centrality, outdegree_centrality,
  closeness_centrality, betweenness_centrality, katz_centrality, pagerank}}
"""

@file "distance.md" """
# Distance
*LightGraphs.jl* includes the following distance measurements:

{{eccentricity, radius, diameter, center, periphery}}
"""


@file "generators.md" """
# Generators

## Random Graphs
*LightGraphs.jl* implements three common random graph generators:

{{erdos_renyi, watts_strogatz, random_regular_graph, random_regular_digraph}}

In addition, [stochastic block model](https://en.wikipedia.org/wiki/Stochastic_block_model)
graphs are available using the following constructs:

{{StochasticBlockModel, make_edgestream}}

`StochasticBlockModel` instances may be used to create Graph objects.

## Static Graphs
*LightGraphs.jl* also implements a collection of classic graph generators:

{{CompleteGraph, CompleteDiGraph, StarGraph, StarDiGraph,PathGraph, PathDiGraph, WheelGraph, WheelDiGraph}}

"""

@file "integration.md" """
# Integration with other packages

*LightGraphs.jl*'s integration with other Julia packages is designed to be straightforward. Here are a few examples.

## [Graphs.jl](http://github.com/JuliaLang/Graphs.jl)
Creating a Graphs.jl `simple_graph` is easy:
```julia
julia> s = simple_graph(nv(g), is_directed=LightGraphs.is_directed(g))
julia> for e in LightGraphs.edges(g)
           add_edge!(s,src(e), dst(e))
       end
```

## [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl)
This excellent graph visualization package can be used with *LightGraphs.jl*
as follows:

```julia
julia> g = WheelGraph(10); am = full(adjacency_matrix(g))
julia> loc_x, loc_y = layout_spring_adj(am)
julia> draw_layout_adj(am, loc_x, loc_y, filename="wheel10.svg")
```
producing a graph like this:
![Wheel Graph](https://cloud.githubusercontent.com/assets/941359/8960521/35582c1e-35c5-11e5-82d7-cd641dff424c.png)

##[TikzGraphs.jl](https://github.com/sisl/TikzGraphs.jl)
Another nice graph visualization package. ([TikzPictures.jl](https://github.com/sisl/TikzPictures.jl)
required to render/save):
```julia
julia> g = WheelGraph(10); t = plot(g)
julia> save(SVG("wheel10.svg"), t)
```
producing a graph like this:
![Wheel Graph](https://cloud.githubusercontent.com/assets/941359/8960499/17f703c0-35c5-11e5-935e-044be51bc531.png)

##[GraphPlot.jl](https://github.com/afternone/GraphPlot.jl)
Another graph visualization package that is very simple to use.
[Compose.jl](https://github.com/dcjones/Compose.jl) is required for most rendering functionality:
```julia
julia> using GraphPlot, Compose
julia> g = WheelGraph(10)
julia> draw(PNG("/tmp/wheel10.png", 16cm, 16cm), gplot(g))
```

##[Metis.jl](https://github.com/JuliaSparse/Metis.jl)
The Metis graph partitioning package can interface with *LightGraphs.jl*:

```julia
julia> g = Graph(100,1000)
{100, 1000} undirected graph

julia> partGraphKway(g, 6)  # 6 partitions
```

##[GraphMatrices.jl](https://github.com/jpfairbanks/GraphMatrices.jl)
*LightGraphs.jl* can interface directly with this spectral graph analysis
package:

```julia
julia> g = PathGraph(10)
{10, 9} undirected graph

julia> a = CombinatorialAdjacency(g)
GraphMatrices.CombinatorialAdjacency{Float64,LightGraphs.Graph,Array{Float64,1}}({10, 9} undirected graph,[1.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,1.0])
```

##[NetworkViz.jl](https://github.com/abhijithanilkumar/NetworkViz.jl)
NetworkViz.jl is tightly coupled with *LightGraphs.jl*. Graphs can be visualized in 2D as well as 3D using [ThreeJS.jl](https://github.com/rohitvarkey/ThreeJS.jl) and [Escher.jl](https://github.com/shashi/Escher.jl).

```julia
#Run this code in Escher

using NetworkViz
using LightGraphs

main(window) = begin
  push!(window.assets, "widgets")
  push!(window.assets,("ThreeJS","threejs"))
  g = CompleteGraph(10)
  drawGraph(g)
end
```

The above code produces the following output :

![alt tag](https://raw.githubusercontent.com/abhijithanilkumar/NetworkViz.jl/master/examples/networkviz.gif)


"""

@file "linalg.md" """
# Linear Algebra

*LightGraphs.jl* provides the following matrix operations on both directed and
undirected graphs:

## Adjacency

{{adjacency_matrix, adjacency_spectrum}}

## Laplacian

{{laplacian_matrix, laplacian_spectrum}}
"""

@file "flowcut.md" """
# Flow and Cut

## Flow
*LightGraphs.jl* provides four algorithms for [maximum flow](https://en.wikipedia.org/wiki/Maximum_flow_problem)
computation:

- [Edmonds–Karp algorithm](https://en.wikipedia.org/wiki/Edmonds%E2%80%93Karp_algorithm)
- [Dinic's algorithm](https://en.wikipedia.org/wiki/Dinic%27s_algorithm)
- [Boykov-Kolmogorov algorithm](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=1316848&tag=1)
- [Push-relabel algorithm](https://en.wikipedia.org/wiki/Push%E2%80%93relabel_maximum_flow_algorithm)

{{maximum_flow}}

## Cut
Stoer's simple minimum cut gets the minimum cut of an undirected graph.

{{mincut}}
"""

@file "operators.md" """
# Operators

*LightGraphs.jl* implements the following graph operators. In general,
functions with two graph arguments will require them to be of the same type
(either both `Graph` or both `DiGraph`).

{{complement, reverse, reverse!, blkdiag, union, intersect, difference, symmetric_difference, induced_subgraph, join, tensor_product, cartesian_product, crosspath}}
"""

@file "pathing.md" """
# Path and Traversal

*LightGraphs.jl* provides several traversal and shortest-path algorithms, along with
various utility functions. Where appropriate, edge distances may be passed in as a
matrix of real number values.

Edge distances for most traversals may be passed in as a sparse or dense matrix
of  values, indexed by `[src,dst]` vertices. That is, `distmx[2,4] = 2.5`
assigns the distance `2.5` to the (directed) edge connecting vertex 2 and vertex 4.
Note that also for undirected graphs `distmx[4,2]` has to be set.

Any graph traversal  will traverse an edge only if it is present in the graph. When a distance matrix is passed in,

1. distance values for undefined edges will be ignored, and
2. any unassigned values (in sparse distance matrices), for edges that are present in the graph, will be assumed to take the default value of 1.0.
3. any zero values (in sparse/dense distance matrices), for edges that are present in the graph, will instead have an implicit edge cost of 1.0.

## Graph Traversal

*Graph traversal* refers to a process that traverses vertices of a graph following certain order (starting from user-input sources). This package implements three traversal schemes:

* `BreadthFirst`,
* `DepthFirst`, and
* `MaximumAdjacency`.

{{bfs_tree, dfs_tree,maximum_adjacency_visit}}

## Random walks
*LightGraphs* includes uniform random walks and self avoiding walks:

{{randomwalk, saw}}


## Connectivity / Bipartiteness
`Graph connectivity` functions are defined on both undirected and directed graphs:

{{is_connected, is_strongly_connected, is_weakly_connected, connected_components, strongly_connected_components, weakly_connected_components, has_self_loop, attracting_components, is_bipartite, condensation, period}}

## Cycle Detection
In graph theory, a cycle is defined to be a path that starts from some vertex
`v` and ends up at `v`.

{{is_cyclic}}

## Shortest-Path Algorithms
### General properties of shortest path algorithms
*  The distance from a vertex to itself is always `0`.
* The distance between two vertices with no connecting edge is always `Inf`.

{{a_star, dijkstra_shortest_paths, bellman_ford_shortest_paths, floyd_warshall_shortest_paths}}

## Path discovery / enumeration

{{gdistances, gdistances!, enumerate_paths}}

For Floyd-Warshall path states, please note that the output is a bit different,
since this algorithm calculates all shortest paths for all pairs of vertices: `enumerate_paths(state)` will return a vector (indexed by source vertex) of
vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)`
will return a vector (indexed by destination vertex) of paths from source `v`
to all other vertices. In addition, `enumerate_paths(state, v, d)` will return
a vector representing the path from vertex `v` to vertex `d`.

### Path States
The `floyd_warshall_shortest_paths`, `bellman_ford_shortest_paths`,
`dijkstra_shortest_paths`, and `dijkstra_predecessor_and_distance` functions
return a state that contains various information about the graph learned during
traversal. The three state types have the following common information,
accessible via the type:

`.dists`
Holds a vector of distances computed, indexed by source vertex.

`.parents`
Holds a vector of parents of each source vertex. The parent of a source vertex
is always `0`.

In addition, the `dijkstra_predecessor_and_distance` function stores the
following information:

`.predecessors`
Holds a vector, indexed by vertex, of all the predecessors discovered during
shortest-path calculations. This keeps track of all parents when there are
multiple shortest paths available from the source.

`.pathcounts`
Holds a vector, indexed by vertex, of the path counts discovered during
traversal. This equals the length of each subvector in the `.predecessors`
output above.
"""

@file "persistence.md" """
# Reading and writing Graphs

Graphs may be written to I/O streams and files using the `save` function and
read with the `load` function. Currently supported graph formats are the
 *LightGraphs.jl* format `lg` and the common formats `gml, graphml, gexf, dot, net`.

{{save, load}}

## Examples
```julia
julia> save(STDOUT, g)
julia> save("mygraph.jgz", g, "mygraph"; compress=true)
julia> g = load("multiplegraphs.jgz")
julia> g = load("multiplegraphs.xml", :graphml)
julia> g = load("mygraph.gml", "mygraph", :gml)
```
"""

@file "matching.md" """
# Matching

## Bipartite Matching
*LightGraphs.jl* supports maximum weight maximal matching computation on bipartite graphs
through linear programming relaxation.  In fact, on bipartite graphs, the solution
of the linear problem is integer.

Installation of the `JuMP` package is required.

{{maximum_weight_maximal_matching}}
"""

@file "community.md" """
# Community Structures
*LightGraphs.jl* contains many algorithm to detect and analize community structures
in graphs.

## clustering coefficients

{{local_clustering_coefficient,local_clustering, global_clustering_coefficient}}

## modularity

{{modularity}}

## community detection

{{community_detection_nback}}

## core-periphery

{{core_periphery_deg}}

## cliques
*LightGraphs.jl* implements maximal clique discovery using

{{maximal_cliques}}

"""
