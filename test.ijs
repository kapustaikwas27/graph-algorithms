load '~temp/graph-algorithms/lib-graph.ijs'

NB. Number of vertices in generated graphs.
VN =: 1 5 10 20 50 100

NB. Graph density (number of edges is DENSITY * number of vertices).
DENSITY =: 3

NB. Max edge weight.
W =: 100

NB. Generate table of edges representing random digraph.
NB. y is number of vertices.
randedges =: (|:@:(?@$~) 2 , DENSITY&*)"0

NB. Generate table of non-negative weighted edges representing random digraph.
NB. y is number of vertices.
randweightededges =: (,. (W ?@$~ #))@randedges

NB. Test lengths of shortest paths by comparing results of 
NB. Bellman-Ford executed from each vertex and Floyd-Warshall.
testbffw =: 3 : 0"0
es =. randweightededges y
bf =. (1 ; 0)&{::"1@:((i. y)&bellmanford_graph_)@:(y&digraph_graph_) es
fw =. floyd_graph_@:(y&matrix_graph_) es
assert. bf -: fw
EMPTY
)

NB. Test lengths of shortest paths by comparing results of 
NB. Bellman-Ford with BFS.
testbfbfs =: 3 : 0"0
es =. (,.&1)@randedges y
g =. (y&digraph_graph_) es
src =. ? y
bf =. 1&{::@:(src&bellmanford_graph_) g
bfs =. (src&bfs_graph_) g
assert. (0&{ bf) -: 0&{ bfs
checkpath =. #@:(0&getpath_graph_)@:(1&{)
assert. (checkpath bf) -: checkpath bfs
EMPTY
)

testbffw VN
testbfbfs VN
