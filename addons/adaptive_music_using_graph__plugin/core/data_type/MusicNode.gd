## Node that holds music segment.
class_name MusicNode
extends Resource

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

func _init(
        id: int,
        name: String,
        music_segment: AudioStream = null,
        after_play_decision: MusicAfterPlayDecision = null
) -> void:
    self.id = id
    self.name = name
    self.music_segment = music_segment
    self.after_play_decision = after_play_decision

    self.resource_name = str("MusicNode ", name if name.length() > 0 else str("#", id))
