NB. Author: Marcin Żołek
NB. Graph processing addon.

load 'format/printf'
load 'graphics/graphviz'

cocurrent 'graph'

NB. Public:

NB. Draw a graph using graphviz addon.
NB. x is array of two boxes of strings. Examples of useful x are 
NB. 'digraph' ; '%d->%d;' or 'digraph' ; '%d->%d [label=%d];' or 'graph' ; '%d--%d;' etc.
NB. Number of %d in string should be equal to number of columns in table of edges.
NB. y is number of vertices ; table of edges with optional attributes.
show =: 4 : 0"1 2
'type fmt' =. x
'vn e' =. y
isolated =. (i. vn) -. ~.@:,@:(2&{."1) e
graphview (type , '{')&, ,&('}' , LF) ,&('%d;' graphstring isolated) fmt graphstring e
)

NB. Convert list of edges to directed graph representation in the form of neighborhood lists.
NB. x is number of vertices (vertices are 0, 1, ..., x - 1).
NB. y is table (rank 2). Each row u v ... represents directed edge u -> v with optional other attributes.
NB. All attributes must be numbers (y is numeric table).
NB. Vertices (u, v) are non-negative integers.
NB. Result:
NB. List of boxed tables. First row of each table is list of neighbors. 
NB. Next rows are optional and depend on other columns of input table.
digraph =: 4 : 0"0 2
g =. x ($ fillval) y
idxs =. {."1 y
(idxs <@:|:/. }."1 y) (~. idxs)} g
)

NB. Convert list of edges to undirected graph representation in the form of neighborhood lists.
NB. x is number of vertices (vertices are 0, 1, ..., x - 1).
NB. y is table (rank 2). Each row u v ... represents undirected edge u <-> v with optional other attributes.
NB. Other details are the same as in digraph.
graph =: (digraph (, revedges))"2

NB. Convert digraph to list of edges.
NB. y is digraph.
NB. Result:
NB. Table (rank 2) of edges with attributes.
edgesfromdigraph =: (i.@:# ;@:(|:@:,&.>) ])"1

NB. Convert graph to list of edges.
NB. y is graph.
NB. Result:
NB. Table (rank 2) of edges with attributes.
NB. Delete pairs of identical edges by sorting and filtering every other.
edgesfromgraph =: everyother@:(/:~)@:sortdirection@:edgesfromdigraph"1

NB. Reverse edges in table of edges.
revedges =: ({~ 1 0 , 2&}.@:i.@:#)&.|:"2

NB. Reverse digraph. Note that reverse of undirected graph is identity, but it works too.
revdigraph =: (# digraph revedges@:edgesfromdigraph)"1

NB. BFS (Breadth first search).
NB. Single-source shortest paths algorithm for unweighted edges (weights are ignored).
NB. x is source vertex.
NB. y is graph.
NB. Result:
NB. Table of lengths of shortest paths from source (row 1) and parents to get paths (row 2).
NB. If parent does not exists then _1 occurs in parent row.
bfs =: 4 : 0"0 1
NB. Initialize arrays, which are updated in place.
notvisit =. x initnotvisit y
dist =. x initdist y
parens =. (_1 $~ #) y
k =. 1 NB. Current distance. It is incremented in each loop iteration.
while. 0 < # x do.
  NB. x is next layer of vertices, p are parents of vertices from x.
  NB.            Delete duplicates.  Filter out visited.  Select candidates for next layer with their parents.
  'x p' =. x |:@:(~:@:({."1) # ])@:(#~ {&notvisit@:({."1))@:;@:([ (,.~ {.)&.>"0 1 {) y
  notvisit =. 0 x} notvisit
  dist =. k x} dist
  parens =. p x} parens
  k =. >: k
end.
dist ,: parens
)

NB. Bellman-Ford algorithm.
NB. Single-source shortest paths algorithm with possible negative edges in O(|V||E|).
NB. x is source vertex.
NB. y is graph.
NB. Result:
NB. * if negative cycle is accessible from a source then 0 ; nonsense table,
NB. * else 1 ; table of lengths of shortest paths from source (row 1) and parents to get paths (row 2).
NB. If parent does not exists then _1 occurs in parent row.
bellmanford =: 4 : 0"0 1
NB. x step y where x is reversed graph and y is current table of lengths of shortest paths and parents from source
NB. calculates new table of lengths and parents (same shape as y) for paths that are 1 edge longer (dynamic programming).
step =. {{ ((|: y)   |:@:relax   ({.   ([  minsel  ({&({. y)@[ + 1&{@]))   ])@>) x }}
NB. Check if negative cycle. Iteration to get distances.
((] ;~ ] (*/@:<:)&{. step)   (step^:(<:@#@[) _1 ,:~ x&initdist))@:revdigraph y
)

NB. Get whole path using result of single source shortest paths algorithm.
NB. x is vertex.
NB. y is array of parents (part of algorithm's result).
NB. Result:
NB. * if the path exists then array of vertices where the first is source and the last is x,
NB. * else (, x).
getpath =: {{ |. }: {&(y , _1)^:a: x }}"0 1

NB. Convert table of edges to adjacency matrix. Useful for Floyd–Warshall algorithm.
NB. If more than one edge u -> v exists than minimal weight is chosen, so result may not be equivalent graph!
NB. x is number of vertices (vertices are 0, 1, ..., x - 1).
NB. y is table (rank 2). Each row u v w ... represents directed edge u -> v with weight w with optional ignored other attributes.
matrix =: 4 : 0"0 2
y =. y (, (,.&0)@:,.~@:i.) x NB. Add edges u -> u with weight 0.
idxs =. 2&{."1 y NB. Edges u -> v are indices (u, v) to adjacency matrix.
ws =. , idxs <.//. 2&{"1 y NB. Weights.
ws (~. idxs)} (2 # x) $ _
)

NB. Floyd–Warshall algorithm.
NB. Computes the shortest paths between each pair of vertices in a digraph with weighted edges.
NB. Assuming that there is no negative cycle.
NB. y is adjacency matrix. 
NB. Note that it means that there is at most two edges (u -> v and u <- v) between each two vertices u, v.
NB. Result has the same shape as y.
NB. https://code.jsoftware.com/wiki/Essays/Floyd
floyd =: 3 : 0"2
for_k. i. # y do.
  y =. y <. k ({"1 +/ {) y
end.
)

NB. Edmonds-Karp algorithm.
NB. TODO

NB. Private:

NB. Filter every other item.
everyother =: (0 1 $~ #) # ]

NB. Initializes distances where x is source and y is graph.
initdist =: {{ (_"0)`(0"0)@.(=&x)@:i.@:# y }}"0 1

NB. Initializes (not yet) visited where x is source and y is graph.
initnotvisit =: {{ (1"0)`(0"0)@.(=&x)@:i.@:# y }}"0 1

NB. Change direction of edges to be u -> v where u <= v.
sortdirection =: (/:~@:(2&{.) , 2&}.)"1

NB. Calculates fill value for [un]digraph.
fillval =: 0 <@:$~ 0 ,~ <:@:{:@:$

NB. Prepares [di]graph for visualization.
graphstring =: {{ x ;@:(<@sprintf"(_&,@:<:@:#@:$ y)) y }}

NB. Min with selection.
NB. Find index of min value in y and return pair 
NB. (min from y , element from x from the same index as min of y or _1 if x is too short).
minsel =: <./@] , ((,&_1@[ {~ ]) (i. <./))

NB. Relax function in graph nomenclature.
relax =: [`]@.(>&({."1))

NB. Ideas:

NB. Dijkstra for shortest paths and Prim for MST algorithms require priority queue.
NB. Priority queue can be implemented in J, but maybe there is other way...

NB. Simplex (linear programming) solves many graph problems. Is there addon for it like for FFTW with external implementation?
