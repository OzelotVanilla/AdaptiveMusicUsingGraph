@tool
class_name MusicGraph
extends Resource
## Sparse graph, containing music node and edge.
# End of class document.


## Array saving reference to node, sorted by node's id, from small to big.
@export var node_array: Array[MusicNode]: get = getAllNodes
var node_dict: Dictionary[int, MusicNode] = {}

## Array saving reference to edge, sorted by edge's id, from small to big.
@export var edge_array: Array[MusicEdge]: get = getAllEdges
var edge_dict: Dictionary[int, MusicEdge] = {}

## Counter used for new node creation.
var node_id_counter: int = 0

## Counter used for new edge creation.
var edge_id_counter: int = 0

## Generated from `node_dict` and `edge_dict`.[br]
##
## Do not directly operate this.
## Using method defined below.[br]
##
## This dict saves the all adjacent node to one node.
## Key: node's id to search for adjacent.
## Value: array of id of all connecting edge of this node (Edge contains `from` and `to` info for node).
var adjacent_dict: Dictionary[int, PackedInt64Array] = {}

func _init(
        node_array: Array[MusicNode] = [],
        edge_array: Array[MusicEdge] = []
) -> void:
    self.node_dict = {}; for n in node_array: self.node_dict[n.id] = n
    self.edge_dict = {}; for e in edge_array: self.edge_dict[e.id] = e
    ## A temp dict storing node's adjacent edge's id. Type: Dictionary[NodeID, Set[EdgeID]].
    var adjacency: Dictionary[int, Dictionary] = {}
    for e in edge_dict.values(): if e is MusicEdge:
        adjacency.get_or_add(e.from_node, {}).set(e.id, null)
        adjacency.get_or_add(e.to_node, {}).set(e.id, null)
    for node_id in adjacency.keys():
        self.adjacent_dict[node_id] = PackedInt64Array(adjacency[node_id].keys())

    # Init the id-counter.
    if node_array.size() > 0:
        node_array.sort_custom(func(a: MusicNode, b: MusicNode): a.id < b.id)
        self.node_id_counter = node_array[-1].id + 1

    if edge_array.size() > 0:
        edge_array.sort_custom(func(a: MusicEdge, b: MusicEdge): a.id < b.id)
        self.edge_id_counter = edge_array[-1].id + 1


func getAdjacentEdgeOfNode(node: MusicNode) -> Array[MusicEdge]:
    return self.getAdjacentEdgeOfNodeByID(node.id)

func getAdjacentEdgeOfNodeByID(node_id: int) -> Array[MusicEdge]:
    if adjacent_dict.has(node_id):
        var edge_ids: PackedInt64Array = adjacent_dict[node_id]
        var edges = []
        for id in edge_ids: edges.append(edge_dict[id])
        return edges
    else:
        return []

## Get the array of the reference to all nodes, sorted by node's id.
func getAllNodes() -> Array[MusicNode]:
    var nodes = self.node_dict.values()
    nodes.sort_custom(func(a: MusicNode, b: MusicNode): a.id < b.id)
    return nodes

## Get the array of the reference to all edges, sorted by edge's id.
func getAllEdges() -> Array[MusicEdge]:
    var edges = self.edge_dict.values()
    edges.sort_custom(func(a: MusicEdge, b: MusicEdge): a.id < b.id)
    return edges

func addNode(id: int, node: MusicNode):
    self.node_dict.set(id, node)

## Remove a node by either its id or itself.
func removeNode(id_or_node: Variant):
    if id_or_node is int:         self.node_dict.erase(id_or_node)
    elif id_or_node is MusicNode: self.node_dict.erase(self.node_dict.find_key(id_or_node))
    else: push_error(str("The arg id_or_node must be"))
