@tool
class_name MusicGraph
extends Resource
## Sparse graph, containing music node and edge.
# End of class document.


## Array saving reference to node, sorted by node's id, from small to big.
@export var node_array: Array[MusicNode] = []:
    get = getAllNodes,
    set = loadFromNodeArray
var node_dict: Dictionary[int, MusicNode] = {}

## Array saving reference to edge, sorted by edge's id, from small to big.
@export var edge_array: Array[MusicEdge] = []:
    get = getAllEdges,
    set = loadFromEdgeArray
var edge_dict: Dictionary[int, MusicEdge] = {}

## Saving the play starting node's id.
@export var starting_node_id: int = -1
var starting_node: MusicNode: get = getStartingNode, set = setStartingNode

## Counter used for new node creation.
var node_id_counter: int = 0

## Counter used for new edge creation.
var edge_id_counter: int = 0

## Generated from `node_dict` and `edge_dict`. Type: [code]Dictionary[NodeID, Set[EdgeID]][/code][br]
##
## Do not directly operate this.
## Using method defined below.[br]
##
## This dict saves the all adjacent node to one node.[br]
## * Key: node's id to search for adjacent.[br]
## * Value: set (impl-ed by [Dictionary]) of id of all connecting edge of this node (Edge contains `from` and `to` info for node).[br]
##
## Since edge is connected from/to the node's slot, but not the nodes itself, so:
##  adjacent node does [b]not[/b] means one of the node must be the following node.
var adjacent_dict: Dictionary[int, Dictionary] = {}


func _init(
        node_array: Array[MusicNode] = [],
        edge_array: Array[MusicEdge] = [],
        starting_node_id: int = -1
) -> void:
    self.node_dict = {}; for n in node_array: self.node_dict[n.id] = n
    self.edge_dict = {}; for e in edge_array: self.edge_dict[e.id] = e

    for e in edge_dict.values(): if e is MusicEdge:
        self.adjacent_dict.get_or_add(e.from_node, {}).set(e.id, null)
        self.adjacent_dict.get_or_add(e.to_node,   {}).set(e.id, null)

    # Init the id-counter.
    if node_array.size() > 0:
        node_array.sort_custom(func(a: MusicNode, b: MusicNode): a.id < b.id)
        self.node_id_counter = node_array[-1].id + 1

    if edge_array.size() > 0:
        edge_array.sort_custom(func(a: MusicEdge, b: MusicEdge): a.id < b.id)
        self.edge_id_counter = edge_array[-1].id + 1

    # Set starting point.
    self.starting_node_id = starting_node_id

func _to_string() -> String: return self.toString()

func toString():
    return str(
        "MusicGraph@{",
        "node_array: ", self.node_array, ", ",
        "edge_array: ", self.edge_array, ", ",
        "starting_node: ", self.starting_node_id,
        "}"
    )

const id_or_node__type_error__message = "The arg id_or_node must be int or MusicNode type."

func getNode(id_or_node: Variant) -> MusicNode:
    assert(id_or_node is int or id_or_node is MusicNode, self.id_or_node__type_error__message)

    if id_or_node is int: return self.node_dict.get(id_or_node)
    else:                 return id_or_node

func getIdOfNode(id_or_node: Variant) -> int:
    assert(id_or_node is int or id_or_node is MusicNode, self.id_or_node__type_error__message)

    if id_or_node is MusicNode: return self.node_dict.find_key(id_or_node)
    else:                       return id_or_node

const id_or_edge__type_error__message = "The arg id_or_edge must be int or MusicEdge type."

func getEdge(id_or_edge: Variant) -> MusicEdge:
    assert(id_or_edge is int or id_or_edge is MusicEdge, self.id_or_edge__type_error__message)

    if id_or_edge is int: return self.edge_dict.get(id_or_edge)
    else:                 return id_or_edge

func getIdOfEdge(id_or_edge: Variant) -> int:
    assert(id_or_edge is int or id_or_edge is MusicEdge, self.id_or_edge__type_error__message)

    if id_or_edge is MusicEdge: return self.node_dict.find_key(id_or_edge)
    else:                       return id_or_edge

## [param id_or_node] can be either node id or MusicNode itself.
func getAdjacentEdgeOfNode(id_or_node: Variant) -> Array[MusicEdge]:
    var node_id := self.getIdOfNode(id_or_node)
    if adjacent_dict.has(node_id):
        ## [code]Dictionary[edge_id, null][/code]
        var edge_ids: Dictionary[int, Variant] = adjacent_dict[node_id]
        var edges = []
        for id in edge_ids.keys(): edges.append(edge_dict[id])
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

## Update the graph by providing [param node_array].
## Used in resource de-serialisation for this class.[br][br]
##
## [b]Notice[/b]: This will only update [member node_dict].
## So it should better to be called with [method loadFromEdgeArray] together.
func loadFromNodeArray(node_array: Array[MusicNode]):
    self.node_dict = {}; for n in node_array: self.node_dict[n.id] = n

    # Init the id-counter.
    if node_array.size() > 0:
        node_array.sort_custom(func(a: MusicNode, b: MusicNode): a.id < b.id)
        self.node_id_counter = node_array[-1].id + 1

## Update the graph by providing [param edge_array].
## Used in resource de-serialisation for this class.[br][br]
##
## [b]Notice[/b]: This will only update [member edge_dict] and [member adjacent_dict].
## So it should better to be called with [method loadFromNodeArray] together.
func loadFromEdgeArray(edge_array: Array[MusicEdge]):
    self.edge_dict = {}; for e in edge_array: self.edge_dict[e.id] = e

    for e in edge_dict.values(): if e is MusicEdge:
        self.adjacent_dict.get_or_add(e.from_node, {}).set(e.id, null)
        self.adjacent_dict.get_or_add(e.to_node,   {}).set(e.id, null)

    # Init the id-counter.
    if edge_array.size() > 0:
        edge_array.sort_custom(func(a: MusicEdge, b: MusicEdge): a.id < b.id)
        self.edge_id_counter = edge_array[-1].id + 1

## Add a node.
func addNode(node: MusicNode):
    self.node_dict.set(node.id, node)

## Remove a node by either its id, or itself.[br]
## All connected edge of this node will also be removed.
func removeNode(id_or_node: Variant):
    var node_id := self.getIdOfNode(id_or_node)

    # Remove all connections first.
    for edge in self.getAdjacentEdgeOfNode(node_id):
        self.removeEdge(edge)

    # Then remove itself.
    self.node_dict.erase(node_id)

## Add an edge connecting two nodes.
func addEdge(id: int, edge: MusicEdge):
    # Add to edge_dict first.
    self.edge_dict.set(id, edge)

    # Then add to adjacency.
    self.adjacent_dict.get_or_add(edge.from_node, {}).set(edge.id, null)
    self.adjacent_dict.get_or_add(edge.to_node,   {}).set(edge.id, null)

## Remove an edge by either its id, or itself.
func removeEdge(id_or_edge: Variant):
    var edge    := self.getEdge(id_or_edge)
    var edge_id := self.getIdOfEdge(id_or_edge)

    # Remove from adjacency list first.
    self.adjacent_dict.get(edge.from_node).erase(edge_id)
    self.adjacent_dict.get(edge.to_node)  .erase(edge_id)

    # Then remove from edge_dict.
    self.edge_dict.erase(edge_id)

func getStartingNode() -> MusicNode:
    return self.node_dict.get(self.starting_node_id)

## Set the starting node of graph.
func setStartingNode(id_or_node: Variant):
    self.starting_node_id = self.getIdOfNode(id_or_node)
