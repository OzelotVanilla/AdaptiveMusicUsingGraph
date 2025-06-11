@tool
class_name MusicGraphEditor
extends GraphEdit
## This class is responsible to maintain the UI and inner data (`graph_store`).
## For each defined method, it should operate on GraphEdit's internal structure to show the UI,
##  and `graph_store: MusicGraph` for saving data.
# End of class document.


## Emit when asked to create new file.
signal create_new_file(path: PackedStringArray)

## Emit when finish creating new file.
signal finished_creating_new_file(path: StringName)

## Emit when asked to close current selected tab.
## The index of the tab, and the file itself will be emitted.
signal close_selected_tab()

## Emit when the node selecting status change.
## With the information of a set recording current selecting nodes.
signal node_select_status_changed(selected_nodes_set: Dictionary[MusicGraphNode, Variant])

## The operation mode of MusicGraphEditor.
enum OperationMode
{
    select,
    move,
    connect,
    single_node_focusing
}

## Current graph showed on the editor UI.
var graph_store: MusicGraph

## Reference of the AMUGResource, used in saving.
var resource_store: AMUGResource

## Counter used for new node creation.
var node_id_counter: int:
    get: return self.graph_store.node_id_counter
    set(value): self.graph_store.node_id_counter = value

## Counter used for new edge creation.
var edge_id_counter: int:
    get: return self.graph_store.edge_id_counter
    set(value): self.graph_store.edge_id_counter = value

## Current operation mode of UI.
var operation_mode: OperationMode:
    set(m):
        #print_debug(str("Set MusicGraphEditor's operation_mode to \"", OperationMode.find_key(m), "\"."))
        operation_mode = m

## The set of current selected music graph node.
var selected_nodes_set: Dictionary[MusicGraphNode, Variant] = {}

## Position of creating new node.
var new_node_position: Vector2 = Vector2.ZERO

@onready var shortcut_manager = MusicGraphEditorShortcutManager.new()
@onready var new_music_graph_dialog: NewMusicGraphDialog = $NewMusicGraphDialog

# func _init() -> void:
#     self.add_child.bind(
#         MusicGraphNode.new(
#             MusicNode.new(1,"Test1", null, null, Vector2(10,10), [
#                 GraphNodeSlotInfo.new(0, GraphNodeSlotInfo.SlotLocation.right),
#                 GraphNodeSlotInfo.new(1, GraphNodeSlotInfo.SlotLocation.right),
#                 GraphNodeSlotInfo.new(2, GraphNodeSlotInfo.SlotLocation.right),
#                 GraphNodeSlotInfo.new(3, GraphNodeSlotInfo.SlotLocation.left),
#             ])
#         )
#     ).call_deferred()
#     self.add_child.bind(
#         MusicGraphNode.new(
#             MusicNode.new(2,"Test2", null, null, Vector2(300,300), [
#                 GraphNodeSlotInfo.new(0, GraphNodeSlotInfo.SlotLocation.left),
#                 GraphNodeSlotInfo.new(1, GraphNodeSlotInfo.SlotLocation.left),
#                 GraphNodeSlotInfo.new(2, GraphNodeSlotInfo.SlotLocation.right),
#             ])
#         )
#     ).call_deferred()
#     var connect_result = self.connect_node("Test1",1,"Test2",1)

func _enter_tree() -> void: return self.__onEnteringSceneTree__()
func _gui_input(event: InputEvent) -> void: return self.__handleGUIInput__(event)
func _shortcut_input(event: InputEvent) -> void: return self.shortcut_manager.handle(self, event)

func __onEnteringSceneTree__():
    pass

func __handleGUIInput__(event: InputEvent):
    # TODO
    # Written in this way to get type hint.
    if event is InputEventMouse: if event.is_pressed():
        var nearest_conn := self.get_closest_connection_at_point(event.position)
        # If found a connection.
        if nearest_conn.size() > 0:
            pass
        self.new_node_position = event.position

func loadGraphFromAMUG(index: int, file: AMUGResource):
    self.graph_store = file.music_graph
    self.resource_store = file
    self.loadGraphFromStore()

func saveGraphToAMUG():
    for c in self.get_children():
        if c is MusicGraphNode:
            c.saveUIInfoToStore()

    ResourceSaver.save(
        AMUGResource.new(IDManager.getIDReassignedMusicGraphOf(self.graph_store)),
        self.resource_store.resource_path
    )

## Load the UI and paramters from `self.graph_store`.
func loadGraphFromStore():
    # TODO
    self.clearUI()

    var node_array := self.graph_store.node_array
    for node in self.graph_store.node_array:
        self.add_child(MusicGraphNode.new(node))

func clearUI():
    self.clear_connections()
    for c in self.get_children(): if c is GraphElement:
        self.remove_child(c)
        c.queue_free()

## Add new node.
## Should operate both UI (`self`) and storage (`graph_store: MusicGraph`).
func addNode():
    var new_node_id = self.node_id_counter
    self.node_id_counter += 1

    var new_node = MusicNode.new(
        new_node_id, str("MusicNode ", new_node_id),
        null, null,
        self.new_node_position + Vector2(20, 40)
    )

    # UI.
    # This `call_deferred` is required, to avoid error when removing the node.
    self.add_child.bind(MusicGraphNode.new(new_node)).call_deferred()

    # Data.
    self.graph_store.addNode(new_node)

    # Avoiding stacking together when called multiple times.
    self.new_node_position += Vector2(20, 40)

func getNode(name: StringName) -> MusicGraphNode:
    return self.get_node(NodePath(name))

## Should operate both UI (`self`) and storage (`graph_store: MusicGraph`).
func removeNode(node: MusicGraphNode) -> void:
    # First disconnect.
    for edge in self.graph_store.getAdjacentEdgeOfNode(node.node_store.id):
        # UI.
        self.disconnect_node(
            self.graph_store.getNode(edge.from_node).name, edge.from_slot,
            self.graph_store.getNode(edge.to_node).name,   edge.to_slot
        )
        # Data: Do not need to remove here. Auto removed in `MusicGraph::removeNode`.

    # Then delete.
    # UI.
    self.remove_child.bind(node).call_deferred()
    # Data.
    self.graph_store.removeNode(node.node_store)

func onSelectingNode(node: GraphElement):
    self.new_node_position = Vector2(node.offset_right, node.offset_top) + Vector2(20, 40)
    if node is MusicGraphNode:
        self.selected_nodes_set.set(node, null)

    self.node_select_status_changed.emit(self.selected_nodes_set)

func onDeselectingNode(node: Node):
    if node is MusicGraphNode:
        self.selected_nodes_set.erase(node)

    self.node_select_status_changed.emit(self.selected_nodes_set)

## Should operate both UI (`self`) and storage (`graph_store: MusicGraph`).
func onConnectingNode(from_node__name: StringName, from_port: int, to_node__name: StringName, to_port: int):
    # TODO: Check if can be connected.
    # UI.
    self.connect_node(from_node__name, from_port, to_node__name, to_port)

    # Data.
    var new_edge_id = self.edge_id_counter
    self.edge_id_counter += 1
    var from_node := self.getNode(from_node__name)
    var to_node   := self.getNode(to_node__name)
    var new_edge = MusicEdge.new(
        new_edge_id, str("MusicEdge ", new_edge_id),
        from_node.node_store.id, from_port,
        to_node.node_store.id,   to_port
    )

## Remove selected node.
## Should operate both UI (`self`) and storage (`graph_store: MusicGraph`).
func onRemovingNode(node_names: Array[StringName]):
    for n in self.selected_nodes_set.keys(): if n is MusicGraphNode:
        self.removeNode(n)

    # Since they are no longer exist, need to update (or, clean) the selected nodes' set.
    self.selected_nodes_set.clear()
    self.node_select_status_changed.emit(self.selected_nodes_set)

## Will call new_music_graph_dialog.
func onCreatingNewFileAction():
    self.new_music_graph_dialog.requestPopup("res://", true)

## After created from new_music_graph_dialog.
func onCreatedNewFile(path: StringName):
    self.finished_creating_new_file.emit(path)

func onSavingAction():
    if self.graph_store != null and self.resource_store != null:
        self.saveGraphToAMUG()

func onClosingAction():
    # TODO: Ask for if whether save for unsaved file.

    self.close_selected_tab.emit()

func onOKToCloseSelected():
    self.close_selected_tab.emit()
