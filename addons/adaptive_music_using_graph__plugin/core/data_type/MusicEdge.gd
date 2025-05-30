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

## Recording node's id.
@export var from_node: int

## Recording node's id.
@export var to_node: int

func _init(
        id: int,
        name: String,
        from_node: int,
        to_node: int
) -> void:
    self.id = id
    self.name = name
    self.from_node = from_node
    self.to_node = to_node

    self.resource_name = str("MusicEdge ", name if name.length() > 0 else str("#", id))
