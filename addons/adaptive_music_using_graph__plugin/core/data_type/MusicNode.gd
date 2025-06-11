@tool
class_name MusicNode
extends Resource
## Node that holds music segment.
# End of class document.

## The id of the node.
## Could be re-assigned for ID reusing purpose.
@export var id: int

## Human-readable name for the node.
## Could be omitted.
@export var name: String = ""

## The music played by this node.
@export var music_segment: AudioStream

## The decision tree of next node, after current node ends playing.
@export var after_play_decision: MusicAfterPlayDecision

## The offset of the position in the GraphEdit's UI.
## Not required in `_init`.
@export var ui_position: Vector2

## Slot information for the node.
@export var slot_info: Array[GraphNodeSlotInfo]

var slot_index_counter: int

func _init(
        id: int,
        name: String,
        music_segment: AudioStream = null,
        after_play_decision: MusicAfterPlayDecision = null,
        ui_position: Vector2 = Vector2.ZERO,
        slot_info: Array[GraphNodeSlotInfo] = []
) -> void:
    # Stored as Resource.
    self.id = id
    self.name = name
    self.music_segment = music_segment
    self.after_play_decision = after_play_decision
    self.ui_position = ui_position
    self.slot_info = slot_info
    self.slot_info.push_front(GraphNodeSlotInfo.createPathInSlot())


    # NOT stored as Resource.
    self.slot_info.sort_custom(func(a: GraphNodeSlotInfo, b: GraphNodeSlotInfo): a.index < b.index)
    self.slot_index_counter = self.slot_info[-1].index + 1

    self.resource_name = str("MusicNode ", name if name.length() > 0 else str("#", id))

func _to_string() -> String:
    return str(
        "MusicNode@{",
        "id: ", self.id, ", ",
        "name: \"", self.name, "\", ",
        "slot_info: \"", self.slot_info, "\", ",
        "}"
    )

func addSlot(slot_location: GraphNodeSlotInfo.SlotLocation):
    var index = self.slot_index_counter
    self.slot_index_counter += 1
    self.slot_info.append(GraphNodeSlotInfo.new(index, slot_location))
