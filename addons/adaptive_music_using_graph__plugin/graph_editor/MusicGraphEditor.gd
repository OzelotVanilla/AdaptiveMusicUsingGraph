@tool
class_name MusicGraphEditor
extends GraphEdit
## This class is responsible to maintain the UI and inner data (`graph_store`).
## For each defined method, it should operate on GraphEdit's internal structure to show the UI,
##  and `graph_store: MusicGraph` for saving data.
# End of class document.


## The operation mode of MusicGraphEditor.
enum OperationMode
{
    select,
    move,
    connect,
    single_node_focusing
}


## Internal storage of the graph.
var graph_store: MusicGraph

## Counter used for new node creation.
var node_id_counter: int

## Counter used for new edge creation.
var edge_id_counter: int

## Current operation mode of UI.
var operation_mode: OperationMode: set = __setOperationMode
func __setOperationMode(m: OperationMode):
    print_debug(str("Set MusicGraphEditor's operation_mode to \"", OperationMode.find_key(m), "\"."))
    operation_mode = m


# TODO
func _init() -> void:
    self.add_child(
        MusicGraphNode.new(
            MusicNode.new(1,"Test1", null, null, Vector2(10,10), [
                GraphNodeSlotInfo.new(0, GraphNodeSlotInfo.SlotLocation.right),
                GraphNodeSlotInfo.new(1, GraphNodeSlotInfo.SlotLocation.right),
                GraphNodeSlotInfo.new(2, GraphNodeSlotInfo.SlotLocation.right),
                GraphNodeSlotInfo.new(3, GraphNodeSlotInfo.SlotLocation.left),
            ])
        )
    )
    self.add_child(
        MusicGraphNode.new(
            MusicNode.new(2,"Test2", null, null, Vector2(300,300), [
                GraphNodeSlotInfo.new(0, GraphNodeSlotInfo.SlotLocation.left),
                GraphNodeSlotInfo.new(1, GraphNodeSlotInfo.SlotLocation.left),
                GraphNodeSlotInfo.new(2, GraphNodeSlotInfo.SlotLocation.right),
            ])
        )
    )
    var connect_result = self.connect_node("Test1",1,"Test2",1)

func _gui_input(event: InputEvent) -> void:
    self.__handleGUIInput__(event)

func __handleGUIInput__(event: InputEvent):
    # TODO
    # Written in this way to get type hint.
    if event is InputEventMouse: if event.is_pressed():
        var nearest_conn := self.get_closest_connection_at_point(event.position)
        # If found a connection.
        if nearest_conn.size() > 0:
            pass

## Load the UI and paramters from `self.graph_store`.
func loadFromGraphStore():
    # TODO
    var node_array := self.graph_store.node_array
    for node in self.graph_store.node_array:
        self.add_child(MusicGraphNode.new(node))
    self.node_id_counter = node_array[-1].id + 1


## Add new node.
## Should operate both UI (`self`) and storage (`graph_store: MusicGraph`).
func addNode():
    # TODO
    pass
