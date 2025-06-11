@tool
class_name MusicEdge
extends Resource
## Edge with evaluate expression.
# End of class document.

## The id of the edge.
## Could be re-assigned for ID reusing purpose.
@export var id: int

## Human-readable name for the edge.
## Could be omitted.
@export var name: String = ""

## Record node's id.
@export var from_node: int

## Record slot's index.
@export var from_slot: int

## Record node's id.
@export var to_node: int

## Record slot's index.
@export var to_slot: int

## [param from_node] and [param to_node] can be either node id or MusicNode itself.
func _init(
        id: int,
        name: String,
        from_node: int,
        from_slot: int,
        to_node: int,
        to_slot: int
) -> void:
    self.id = id
    self.name = name
    self.from_node = from_node
    self.from_slot = from_slot
    self.to_node = to_node
    self.to_slot = to_slot

    self.resource_name = str("MusicEdge ", name if name.length() > 0 else str("#", id))
