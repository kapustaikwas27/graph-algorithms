NB. Example.
NB. Run in Edit window (Jqt required for graphviz https://code.jsoftware.com/wiki/Addons/graphics/graphviz).

load '~temp/graph-algorithms/tree.ijs'

NB. Edges of a tree.
]e =: _2]\ 0 1  0 2  1 3  1 4  1 5  2 6  2 7  2 8  4 9  4 10  5 11  7 12  10 13
NB. Weights.
]w =: 100 ?~ # e
NB. Weighted edges.
]ew =: e ,. w
NB. Tree representation without weights of edges.
]t =: treeFromEdges_tree_ e
NB. Show it. This will open first graphviz window. Note that graphviz windows may overlap.
'%d->%d;' show_tree_ e
NB. Tree representation with weights of edges.
]tw =: treeFromEdges_tree_ ew
NB. Show it. This will open second graphviz window.
'%d->%d [label=%d];' show_tree_ ew
NB. Calculate level order, preorder and postorder.
order_tree_ t
NB. Weights of edges does not change any order.
(order_tree_ t) -: order_tree_ tw

NB. Measure performance.

NB. Generate edges of complete (or almost complete without full last level of leaves depending on given number of vertices)
NB. regular tree (regular means that each vertex except leaves has the same number of children).
NB. x is regularity (number of children). x >= 1.
NB. y is number of vertices. y >= 2.
genRegEdges =: ((<:@] $ [ # i.@:(>.@%~)) ,. }.@:i.@])"0

NB. Example of usage of genRegEdges.
'%d->%d;' show_tree_ 1 genRegEdges 5
'%d->%d;' show_tree_ 2 genRegEdges 12

NB. Create 3-regular, almost complete tree with million vertices.
e =: 3 genRegEdges 1e6
t =: treeFromEdges_tree_ e
NB. Execute order_tree_ 5 times and get average execution time and get allocated space.
timeSpace =: 6!:2 , 7!:2@]
5 timeSpace 'order_tree_ t'
NB. Compare it with your recursive implementation in J or your second favorite language :-).
NB. Note that above timing does not include time spent for generating tree representation from table of edges.

0 : 0
It is also easy to use in jconsole with reading table of edges from standard input (one line with end of line per edge):
stdout@(,&LF)@":"1@:order_tree_@:treeFromEdges_tree_@:(".;._2)@:stdin ''
exit ''
)
