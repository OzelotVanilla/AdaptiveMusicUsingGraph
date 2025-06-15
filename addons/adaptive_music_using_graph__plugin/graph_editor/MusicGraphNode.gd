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
    for i in self.node_store.strategy_slots:
        var slot_content: Control

        match i.type:
            StrategySlot.Type.none:
                slot_content = Label.new()
                slot_content.text = "Not-Set-Yet"
            StrategySlot.Type.global_input:
                slot_content = Label.new()
                slot_content.text = "Input"
            StrategySlot.Type.status_change:
                slot_content = Label.new()
                slot_content.text = "Status"
            StrategySlot.Type.expression:
                slot_content = Label.new()
                slot_content.text = "Expr"
            StrategySlot.Type.default:
                slot_content = Label.new()
                slot_content.text = "Otherwise"
            StrategySlot.Type.through:
                slot_content = Label.new()
                slot_content.text = "Go-Through"

        # Add wrapping panel and its style (border). Use panel for stability for `add_theme_stylebox_override` method.
        var wrapping_panel = PanelContainer.new()
        wrapping_panel.add_child(slot_content)
        self.add_child(wrapping_panel)
        self.setPortBySlotInfo(i)

func clearAllSlots() -> void:
    # Clear port (Godot's slot).
    self.clear_all_slots()

    # Clear element
    for node in self.get_children():
        self.remove_child(node)
        node.queue_free()

func saveUIInfoToStore():
    node_store.ui_position = self.position_offset

func setPortBySlotInfo(info: StrategySlot):
    self.set_slot(
        info.index,
        true if info.location == StrategySlot.PortLocation.left or info.location == StrategySlot.PortLocation.both
                else false,
        info.connection_category,
        info.colour,
        true if info.location == StrategySlot.PortLocation.right or info.location == StrategySlot.PortLocation.both
                else false,
        info.connection_category,
        info.colour
    )

## Should operate both UI (`self`) and Data (`node_store: MusicNode`).
func addInOutSlot() -> void:
    # Data.
    self.node_store.addSlot(StrategySlot.PortLocation.both)

    # UI.
    self.loadSlotInfoFromStore()

## Should operate both UI (`self`) and Data (`node_store: MusicNode`).
func addOutSlot() -> void:
    # Data.
    self.node_store.addSlot(StrategySlot.PortLocation.right)

    # UI.
    self.loadSlotInfoFromStore()

func _to_string() -> String:
    return str(
        "MusicGraphNode@{",
        "node_store: ", self.node_store,
        "}"
    )
