@tool
class_name MusicGraphNode
extends GraphNode
## UI representation in MusicGraphEditor
##
## This class contains the original MusicNode.
# End of class document.

signal slot_being_clicked(node: MusicGraphNode, slot: StrategySlot)

## Whether the representing [code]MusicNode[/code] is a starting point of the graph.
var is_starting_node: bool = false

func _draw() -> void: return self.onRedraw()
func _to_string() -> String: return self.toString()

var node_store: MusicNode


func _init(music_node: MusicNode) -> void:
    self.node_store = music_node
    for s in self.node_store.strategy_slots:
        self.connectToSlot(s)
    self.loadFromStore()

## Connect to the signal (e.g., "slot_changed") for newly add slot.[br]
## Should only be called if a new slot is added.
func connectToSlot(slot: StrategySlot):
    slot.slot_changed.connect(self.onSlotChanged)

## Clear connection to slot's signal (e.g., "slot_changed").[br]
## Should only be called if a slot will be deleted.
func disconnectToSlot(slot: StrategySlot):
    if slot.has_connections("slot_changed"):
        slot.disconnect("slot_changed", self.onSlotChanged)

## This reload the whole UI-related info from storage.
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
        var slot_content: Control = self.generateSlotShowingContent(i)

        # Add wrapping panel and its style (border). Use panel for stability for `add_theme_stylebox_override` method.
        var wrapping_panel = PanelContainer.new()
        wrapping_panel.add_child(slot_content)
        wrapping_panel.connect(
            "gui_input",
            func(event: InputEvent):
                if event is InputEventMouse: if event.is_pressed():
                    self.slot_being_clicked.emit(self, i)
        )
        self.add_child(wrapping_panel)
        self.setPortBySlotInfo(i)

## Must be the slot that is already loaded/showed in the UI.
func reloadSpecificSlotFromStorage(index: int):
    # Not exist.
    if index < 0 or index > self.get_child_count() - 1:
        push_error("Index ", index, " is out-of-bound. Child count is ", self.get_child_count(), ".")
        return

    # Get showing content from slot info.
    var slots := self.node_store.strategy_slots

    # Remove then add new.
    var old_wrapping_panel = self.get_child(index)
    for c in old_wrapping_panel.get_children(): old_wrapping_panel.remove_child(c)
    old_wrapping_panel.add_child(self.generateSlotShowingContent(slots[index]))

    # Incase the slot info was also changed
    self.setPortBySlotInfo(slots[index])

    # Redraw if the width need to change correspondantely.
    self.queue_redraw()

func generateSlotShowingContent(slot: StrategySlot) -> Control:
    var slot_content = Label.new()
    slot_content.text = slot.title
    return slot_content

func clearAllSlots() -> void:
    # Clear port (Godot's slot).
    self.clear_all_slots()

    # Clear element
    for node in self.get_children():
        self.remove_child(node)
        node.queue_free()

func saveUIInfoToStore():
    node_store.ui_position = self.position_offset

func setPortBySlotInfo(slot: StrategySlot):
    var index = self.node_store.strategy_slots.find(slot)
    self.set_slot(
        index,
        true if slot.location == StrategySlot.PortLocation.left or slot.location == StrategySlot.PortLocation.both
                else false,
        slot.connection_category,
        slot.colour,
        true if slot.location == StrategySlot.PortLocation.right or slot.location == StrategySlot.PortLocation.both
                else false,
        slot.connection_category,
        slot.colour
    )

## Should operate both UI (`self`) and Data (`node_store: MusicNode`).
func addInOutSlot() -> void:
    # # Data.
    var slot: StrategySlot
    slot = self.node_store.addSlot(StrategySlot.PortLocation.both)
    # # Signal.
    self.connectToSlot(slot)

    # # UI.
    self.loadSlotInfoFromStore()

## Should operate both UI (`self`) and Data (`node_store: MusicNode`).
func addOutSlot() -> void:
    # # Data.
    var slot: StrategySlot
    slot = self.node_store.addSlot(StrategySlot.PortLocation.right)
    # # Signal.
    self.connectToSlot(slot)

    # # UI.
    self.loadSlotInfoFromStore()

## Get the slot with the left port (input port), for given index of left port. Returns [code]null[/code] if not found.[br]
## For example:[br]
## * [code]in SlotA out[/code][br]
## * [code]-- SlotB out[/code][br]
## * [code]in SlotC ---[/code][br]
## Then, for [param index] is [code]0[/code], returns [code]SlotA[/code].
## For [param index] is [code]1[/code], returns [code]SlotC[/code].
func getSlotWithLeftPortIndexAt(index: int) -> StrategySlot:
    return self.node_store.strategy_slots.get(self.get_input_port_slot(index))

## Get the slot with the right port (output port), for given index of right port. Returns [code]null[/code] if not found.[br]
## For example:[br]
## * [code]in SlotA out[/code][br]
## * [code]-- SlotB out[/code][br]
## * [code]in SlotC ---[/code][br]
## Then, for [param index] is [code]0[/code], returns [code]SlotA[/code].
## For [param index] is [code]1[/code], returns [code]SlotB[/code].
func getSlotWithRightPortIndexAt(index: int) -> StrategySlot:
    return self.node_store.strategy_slots.get(self.get_output_port_slot(index))

## This only affect UI.
func setToStartingNodeStyle():
    # Avoid unnecessary set.
    if not self.is_starting_node:
        self.is_starting_node = true
        self.queue_redraw()

## This only affect UI.
func setToNormalStyle():
    # Avoid unnecessary set.
    if self.is_starting_node:
        self.is_starting_node = false
        self.queue_redraw()

## Indicates the slot being changed.
## If [param index] is [code]-1[/code], reload all.
func onSlotChanged(slot: StrategySlot):
    var index = self.node_store.strategy_slots.find(slot)
    self.reloadSpecificSlotFromStorage(index)

## This draws a thin border for the starting node.
func onRedraw():
    if self.is_starting_node:
        self.draw_rect(
            Rect2(Vector2.ZERO - Vector2(4, 8), self.size + Vector2(8, 12)),
            Color("#decafe"),
            false,
            2
        )

func toString() -> String:
    return str(
        "MusicGraphNode@{",
        "node_store: ", self.node_store,
        "}"
    )
