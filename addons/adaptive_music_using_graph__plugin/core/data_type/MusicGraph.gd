## Sparse graph, containing music node and edge.
class_name MusicGraph
extends Resource

@export var node_array: Array[MusicNode]: get = getAllNodes
var node_dict: Dictionary[int, MusicNode] = {}

@export var edge_array: Array[MusicEdge]: get = getAllEdges
var edge_dict: Dictionary[int, MusicEdge] = {}

## Generated from `node_dict` and `edge_dict`.
## Do not directly operate this.
## Using method defined below.
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
