@tool
class_name SlotControlBar
extends HBoxContainer
## Contains the slot.


func generateControlFromNode(node: MusicGraphNode):
    self.clear()

    for slot in node.node_store.strategy_slots:
        self.add_child(SlotControl.new(slot))

func clear():
    for c in self.get_children(): if c is SlotControl:
        self.remove_child(c)
        c.queue_free()
