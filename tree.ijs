NB. Author: Marcin Żołek
NB. Tree processing addon.

0 : 0
I came up with a non-recursive, linear, fast way to compute
level, pre and post order for any rooted tree using J features
without performing depth-first search.
To make examples of usage more understandable I used graphviz addon,
which is available in Jqt, to visualize example trees.

Graphviz addon uses external program which may require
additional (easy) installation described in JWiki.
https://code.jsoftware.com/wiki/Addons/graphics/graphviz
It is used only for visualization (verb show).

I recommend using graphviz with J9.6.
)

load 'format/printf'
load 'graphics/graphviz'

cocurrent 'tree'

NB. Enum to access elements from tree representation using names instead of numbers
NB. for example LVLS&{:: instead of 2&{::
NB. Tree representation is described in treeFromEdges.
(consts) =: i. # ;: consts =: 'ROOT NEIGHBORS LVLS'

NB. Draw a tree using graphviz addon (Jqt only!).
NB. x is format string. Examples of useful x are
NB. '%d->%d;' or '%d->%d [label=%d];' etc.
NB. Number of %d in string should be equal to number of columns in table of edges.
NB. y is table of edges with optional attributes (additional columns such as weights of edges).
NB. It opens graphviz window with displayed tree.
show =: 4 : 0"1 2
NB. Prepares table of edges of a tree for visualization.
graphString =. {{ x ;@:(<@sprintf"(_&,@:<:@:#@:$ y)) y }}
graphview 'digraph{'&, ,&('}' , LF) x graphString y
)

NB. Convert non-empty list of edges to representation of rooted tree in the form of neighborhood lists.
NB. y is table (rank 2). Each row u v ... represents directed edge u -> v from parent to child with optional other attributes.
NB. All attributes must be numbers (y is numeric table).
NB. Vertices u, v are non-negative integers from set {0, 1, ..., |V| - 1} where |V| is number of vertices in tree.
NB. Result:
NB. Represeantation of a tree consists of array of boxes (access to each box should use consts defined at the beginning of addon).
NB. 0. Root.
NB. 1. Neighbors is list of boxed tables. First row of each table is list of neighbors.
NB.    Next rows are optional and depend on other columns of input table.
NB. 2. Levels of a tree (array of boxes where in each box there are vertices from each level).
treeFromEdges =: 3 : 0"2
fillVal =. 0 <@:$~ 0 ,~ <:@:{:@:$
NB. Root is the only vertex that does not occur in second column of edges (root is not a child of any vertex).
root =. <@:I. 0:`(1&{"1@])`(1 $~ >:@:#@])}~ y
NB. Neighborhood list is created with empty contents and then boxes for vertices which are not leaves are updated.
neighbors =. (>:@:# ($ fillVal) ]) y
idxs =. {."1 y
neighbors =. (idxs <@:|:/. }."1 y) (~. idxs)} neighbors
NB. Calculate levels.
lvls =. }: ;@:({.&.>)@:({&neighbors)&.>^:a: root
NB. Merge results to create representation.
root , (< neighbors) , < lvls
)

NB. Calculate level, pre and post order of rooted tree.
NB. y is tree representation computed with treeFromEdges.
NB. Result:
NB. 3-row table. Row 0 is level order, row 1 is preorder, row 2 is postorder.
order =: 3 : 0"1
NB. Level order is almost calculated, because it is ; LVLS&{:: y
lvls =. LVLS&{:: y
NB. Get number of children of each vertex.
children =. #@:{.@> NEIGHBORS&{:: y
NB. Compute sizes of each subtree.
NB. Each iteration of fold calculates the sizes for all the vertices of one level of the tree starting from the lowest level.
NB. Left argument in fold is boxed array of vertices from current level.
NB. Right argument in fold is numeric array of results from previous level.
NB. Result for current level can be calculated by substacting prefix sums of result from previous level.
NB. We use the number of children of vertices from the current level to determine for each vertex from the level which prefix sums to choose.
sizes =. |. (0 $ 0) <F::(+/\@:({&children)@>@[ ({ >:@:- 0&,@:}:@[ { ]) 0&,@:(+/\)@]) lvls
NB. Postorder and preorder can be calculated similarly using subtree sizes.
NB. This time calculation is from the root downwards.
NB. That's why F:: is used in sizes and F:. in preIdxs, postIdxs.
both =. lvls ,:&.> sizes
prepare =. (,: +/\)@:({&children)
NB. Left argument in fold is element from noun both.
NB. Right argument is 3-row table where
NB. row 0 is pre (in preIdxs) or post (in postIdxs) order of previous level,
NB. row 1 is array of numbers of children of vertices from previous level,
NB. row 2 is array of prefix sums of row 1.
NB. There are a few optimizations in the code and details are omitted.
preIdxs =. ; _1 1 1 <@:{.F:.(>@[  (prepare@:{.@[ ,~ (1&{ # {.)@] >:@:+ (] (0 0&,)@:(+/\)@:}:@:(0:`((*@:(1&{) <:@:# {:)@[)`]}) {:@[) (}.@[ - {~) (1&{ # 0&,@:}:@:{:)@])  ]) both
postIdxs =. ; (1 1 ,~ # children) <@:{.F:.(>@[  (prepare@:{.@[ ,~ (1&{ # {.)@] <:@:- (] (,&0 0)@:(+/\.)@:}.@:(0:`((*@:(1&{) }:@:# {:)@[)`]}) {:@[) (}:@[ - {~) (1&{ # {:)@])  ]) both
NB. Convert preIdxs and postIdxs to preorder and postorder.
put =. ]`[`(0 $~ #@])}
lvlOrd =. ; lvls
preOrd =. preIdxs put lvlOrd
postOrd =. postIdxs put lvlOrd
lvlOrd , preOrd ,: postOrd
)

NB. Example of usage.
cocurrent 'base'
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
]order_tree_ t
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
It is also easy to use it in jconsole with reading table of edges from standard input (one line with end of line per edge):
stdout@(,&LF)@":"1@:order_tree_@:treeFromEdges_tree_@:(".;._2)@:stdin ''
exit ''
)
