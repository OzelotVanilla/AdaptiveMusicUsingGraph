@tool
## Re-assign the id to the music node or edge in the graph.
class_name IDManager
extends RefCounted

static func getIDReassignedMusicGraphOf(graph: MusicGraph) -> MusicGraph:
    # Create a dict to store the mapping from old to new id.
    var node_new_id_dict: Dictionary[int, int] = {}
    var node_new_id_counter: int = 0
    var edge_new_id_dict: Dictionary[int, int] = {}
    var edge_new_id_counter: int = 0

    var nodes = graph.getAllNodes()
    nodes.sort_custom(func(a: MusicNode, b: MusicNode): a.id < b.id)
    var edges = graph.getAllEdges()
    edges.sort_custom(func(a: MusicEdge, b: MusicEdge): a.id < b.id)

    # Iterate all keys to create mapping to new id.
    for n in nodes:
        node_new_id_dict[n.id] = node_new_id_counter
        node_new_id_counter += 1
    for e in edges:
        edge_new_id_dict[e.id] = edge_new_id_counter
        edge_new_id_counter += 1

    # Iterate all keys to give new id.
    var new_node_array: Array[MusicNode] = []
    var new_edge_array: Array[MusicEdge] = []
    for n in nodes:
        n.id = node_new_id_dict[n.id]
        new_node_array.append(n)
    for e in edges:
        e.id = edge_new_id_dict[e.id]
        e.from_node = node_new_id_dict[e.from_node]
        e.to_node   = node_new_id_dict[e.to_node]
        new_edge_array.append(e)

    return MusicGraph.new(new_node_array, new_edge_array, graph.starting_node_id)
