NB. Example.
NB. Run in Edit window (Jqt required for graphviz https://code.jsoftware.com/wiki/Addons/graphics/graphviz).

load '~temp/graph-algorithms/lib-graph.ijs'

]gvn =: 7 NB. Number of vertices is 7.
]ge =: _3]\ 1 2 6  1 4 7  2 3 5  2 4 8  2 5 _4  3 2 _2  4 3 _3  4 5 9  5 1 2  5 3 7 NB. List of edges with weights.
]g1 =: gvn digraph_graph_ ge NB. Create a digraph.
]g2 =: gvn graph_graph_ ge NB. Create a graph.
('digraph' ; '%d->%d [label=%d];')&show_graph_ gvn ; ge NB. Visualize g1.

NB. Bellman-Ford.
]r =: 1 bellmanford_graph_ g1 NB. Calculate shortest paths in graph g1 from vertex 1.
2 getpath_graph_ (1 ; 0)&{:: r NB. Show path from vertex 2.
('graph' ; '%d--%d [label=%d];')&show_graph_ gvn ; edgesfromgraph_graph_ g2 NB. Visualize g2.
]r =: 2 bellmanford_graph_ g2 NB. Negative cycle (undirected negative edge).

NB. Floyd-Warshall.
m =: _6]\0 2 5 _ _ _ _ 0 4 1 3 _ _ _ 0 _ _2 _ _ _ 4 0 _ 5 _ _ _ _1 0 6 _ _ _ _ _ 0
floyd_graph_ m
floyd_graph_ 2 matrix_graph_ _3]\ 0 1 4  0 1 2

NB. BFS.
g3vn =: 9
g3e =: _2]\ 0 1  0 2  1 3  3 4  1 4  3 8  4 8  4 5  2 5  2 6  2 7  7 0  7 6  6 8
('digraph' ; '%d->%d;')&show_graph_ g3vn ; g3e
g3 =: g3vn digraph_graph_ g3e
]r =: 0 bfs_graph_ g3
8 getpath_graph_ 1 { r
