@tool
class_name SlotControlBar
extends HBoxContainer
## Contains the slot.
# End of class document.


const slot_control_scene := preload("res://addons/adaptive_music_using_graph__plugin/editor/bottom_panel/SlotControl.tscn")
var message__select_a_node_to_start: Label:
    get:
        var label = Label.new()
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
        label.text = "Select a node to adjust its slots."
        return label
var message__too_many_node_selected: Label:
    get:
        var label = Label.new()
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
        label.text = "Select only one node to adjust slots."
        return label

## Record the reference to the node which provide info for the UI.
var info_from_node: MusicGraphNode

func generateControlFromNode(node: MusicGraphNode):
    self.clear()
    self.info_from_node = node

    for slot in node.node_store.strategy_slots:
        var slot_control: SlotControl = slot_control_scene.instantiate()
        slot_control.init(slot)
        self.add_child(slot_control)

func focusOnNodeByIndex(index: int):
    var node: SlotControl = self.get_child(index)
    node.title.grab_focus()

func showSelectNodeToStart():
    self.clear()
    self.add_child(self.message__select_a_node_to_start)

func showTooManyNodesSelected():
    self.clear()
    self.add_child(self.message__too_many_node_selected)

func clear():
    self.info_from_node = null
    for c in self.get_children():
        self.remove_child(c)
        c.queue_free()
