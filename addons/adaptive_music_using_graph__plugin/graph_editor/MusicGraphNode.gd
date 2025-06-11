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
    self.loadSlotInfoFromStore()

## This load all slot from the storage node.[br]
## Notice that the slot here is different from Godot's.
## The slot contains in/out port and its panel for showing information.
func loadSlotInfoFromStore():
    # Clean existed content first.
    self.clearAllSlots()

    # Add from storage.
    for i in self.node_store.slot_info:
        var slot_content: Control

        # If path-in slot (index 0 and only has left connection).
        if i.index == 0 and i.location == GraphNodeSlotInfo.SlotLocation.left:
            slot_content = Label.new()
            slot_content.text = "Input"
        else:
            slot_content = Label.new()
            slot_content.text = "Test"

        self.add_child(slot_content)
        self.setSlotBySlotInfo(i)

func clearAllSlots() -> void:
    # Clear port (Godot's slot).
    self.clear_all_slots()

    # Clear element
    for node in self.get_children():
        self.remove_child(node)
        node.queue_free()

func saveUIInfoToStore():
    node_store.ui_position = self.position_offset

func setSlotBySlotInfo(info: GraphNodeSlotInfo):
    self.set_slot(
        info.index,
        true if info.location == GraphNodeSlotInfo.SlotLocation.left or info.location == GraphNodeSlotInfo.SlotLocation.both
                else false,
        info.connection_category,
        info.colour,
        true if info.location == GraphNodeSlotInfo.SlotLocation.right or info.location == GraphNodeSlotInfo.SlotLocation.both
                else false,
        info.connection_category,
        info.colour
    )

## Should operate both UI (`self`) and Data (`node_store: MusicNode`).
func addInOutSlot() -> void:
    # Data.
    self.node_store.addSlot(GraphNodeSlotInfo.SlotLocation.both)

    # UI.
    self.loadSlotInfoFromStore()

## Should operate both UI (`self`) and Data (`node_store: MusicNode`).
func addOutSlot() -> void:
    # Data.
    self.node_store.addSlot(GraphNodeSlotInfo.SlotLocation.right)

    # UI.
    self.loadSlotInfoFromStore()


func _to_string() -> String:
    return str(
        "MusicGraphNode@{",
        "node_store: ", self.node_store,
        "}"
    )
