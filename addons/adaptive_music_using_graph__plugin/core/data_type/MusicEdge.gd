@tool
class_name MusicEdge
extends Resource
## Edge with evaluate expression.
# End of class document.

## The id of the edge.
## Could be re-assigned for ID reusing purpose.
@export var id: int = -1

## Human-readable name for the edge.
## Could be omitted.
@export var name: String = ""

## Record node's id.
@export var from_node: int = -1

## Record slot's index.
@export var from_slot: int = -1

## Record node's id.
@export var to_node: int = -1

## Record slot's index.
@export var to_slot: int = -1

## [param from_node] and [param to_node] can be either node id or MusicNode itself.[br][br]
##
## [b]Notice[/b]: Should specify all params here.
## Having default value here only for resource saving/loading purpose.
func _init(
        id: int = -1,
        name: String = "",
        from_node: int = -1,
        from_slot: int = -1,
        to_node: int = -1,
        to_slot: int = -1
) -> void:
    self.id = id
    self.name = name
    self.from_node = from_node
    self.from_slot = from_slot
    self.to_node = to_node
    self.to_slot = to_slot

    self.resource_name = str("MusicEdge ", name if name.length() > 0 else str("#", id))

func _to_string() -> String:
    return str(
        "MusicEdge@{",
        "id: ", self.id, ", ",
        "name: \"", self.name, "\", ",
        "from_node: ", self.from_node, ", ",
        "from_slot: ", self.from_slot, ", ",
        "to_node: ", self.to_node, ", ",
        "to_slot: ", self.to_slot, ", ",
        "}"
    )
