@tool
class_name MusicGraphNode
extends GraphNode
## UI representation in MusicGraphEditor
##
## This class contains the original MusicNode.
# End of class document.

var node_store: MusicNode

func _init(music_node: MusicNode) -> void:
    self.node_store = music_node
    self.loadFromStore()

func loadFromStore():
    self.position_offset = self.node_store.ui_position
    self.name = self.node_store.name
    self.title = self.node_store.name
    for i in self.node_store.slot_info:
        # If path-in slot (index 0 and only has left connection).
        if i.index == 0 and i.location == GraphNodeSlotInfo.SlotLocation.left:
            var label = Label.new()
            label.text = "In"
        else:
            var label_test = Label.new()
            label_test.text = "Test"
            self.add_child(label_test)

        self.set_slot(
            i.index,
            true if i.location == GraphNodeSlotInfo.SlotLocation.left else false,
            i.connection_category,
            i.colour,
            true if i.location == GraphNodeSlotInfo.SlotLocation.right else false,
            i.connection_category,
            i.colour
        )

func saveUIInfoToStore():
    node_store.ui_position = self.position_offset

func _to_string() -> String:
    return str(
        "MusicGraphNode@{",
        "node_store: ", self.node_store,
        "}"
    )
