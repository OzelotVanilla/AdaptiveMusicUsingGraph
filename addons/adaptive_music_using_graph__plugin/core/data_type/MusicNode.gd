@tool
class_name MusicNode
extends Resource
## Node that holds music segment.
# End of class document.


## The id of the node.
## Could be re-assigned for ID reusing purpose.
@export var id: int = -1

## Human-readable name for the node.
## Could be omitted.
@export var name: String = ""

## The music played by this node.
@export var music_segment_path: StringName = ""

var music_segment: AudioStream:
    get:
        return util.loadAudioStreamFromFile(self.music_segment_path)

## The offset of the position in the GraphEdit's UI.
## Not required in `_init`.
@export var ui_position: Vector2

## The stategy slot information, containing after-playing decision at different condition.
@export var strategy_slots: Array[StrategySlot]

var slot_index_counter: int

## [b]Notice[/b]: Should specify the [param id] and [param name] here.
## Having default value here only for resource saving/loading purpose.
func _init(
        id: int = -1,
        name: String = "",
        music_segment: AudioStream = null,
        ui_position: Vector2 = Vector2.ZERO,
        strategy_slots: Array[StrategySlot] = []
) -> void:
    # Stored as Resource.
    self.id = id
    self.name = name
    self.music_segment = music_segment
    self.ui_position = ui_position
    self.strategy_slots = strategy_slots
    if self.strategy_slots.size() == 0: # Add global-input
        self.addSlot(StrategySlot.PortLocation.left)
    self.strategy_slots.sort_custom(func(a: StrategySlot, b: StrategySlot): a.index < b.index)

    # NOT stored as Resource.
    self.resource_name = str("MusicNode ", name if name.length() > 0 else str("#", id))

func _to_string() -> String:
    return str(
        "MusicNode@{",
        "id: ", self.id, ", ",
        "name: \"", self.name, "\", ",
        "strategy_slots: \"", self.strategy_slots, "\", ",
        "music_segment_path: \"", self.music_segment_path, "\", ",
        "}"
    )

## Return the newly add slot.
func addSlot(port_location: StrategySlot.PortLocation) -> StrategySlot:
    #var index = self.slot_index_counter
    #self.slot_index_counter += 1
    var slot_type
    match port_location:
        StrategySlot.PortLocation.left:
            slot_type = StrategySlot.EvalType.global_input
        StrategySlot.PortLocation.right:
            slot_type = StrategySlot.EvalType.none
        StrategySlot.PortLocation.both:
            slot_type = StrategySlot.EvalType.through

    var result = StrategySlot.new(port_location, slot_type)
    self.strategy_slots.append(result)
    return result

## Evaluate according to the runtime param.
## [code]-1[/code] means no available node next.[br][br]
##
## For the in-path connected into main input, the precedence of the evaluation is:[br][br]
##
## 1. area_change. If match, produce 100% fitness. [br]
## 2. status_change. If match, produce 100% fitness. [br]
## 3. expression_group.
##    Groups will generate fitness by group-expression first,
##     then if a group is picked, the slot expression will calculate fitness.
##    By default, group-expression provides 100% fitness. [br]
## 4. default. Could be set with a fixed fitness value. [br]
func evaluate(env: AMUGGameEnv) -> int:
    # TODO Not completed.
    var next_edge__id: int = -1

    # 1. See if there are area change slots.
    var area_change_slots: Array[StrategySlot] = self.strategy_slots.filter(
        func(s: StrategySlot): return s.type == StrategySlot.EvalType.area_change
    )
    for slot in area_change_slots:
        if slot.area_change__target == env.current_area:
            return slot.to_edge

    # 2. See if there are status change slots.
    var status_change_slots = self.strategy_slots.filter(
        func(s: StrategySlot): return s.type == StrategySlot.EvalType.status_change
    )

    # 4. See if there is "otherwise" (default) slot.
    var otherwise_slots: Array[StrategySlot] = self.strategy_slots.filter(
        func(s: StrategySlot): return s.type == StrategySlot.EvalType.default
    )
    if otherwise_slots.size() == 1:
        return otherwise_slots[0].to_edge

    return next_edge__id
