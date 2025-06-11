class_name GraphNodeSlotInfo
extends Resource
## Class for storing the single GraphNode slot info
##
##
# End of class document.

enum SlotLocation
{
    left,
    right,
    both
}

## Index of the slot. Different for left/right side.
@export var index: int

## The location of the slot on the node.
@export var location: SlotLocation

const default_connection_category = 0
## `type_left`/`type_right` for the slot. By default, set to 0 in this project.
@export var connection_category: int = default_connection_category

const default_colour = Color(0.7, 0.7, 0.7, 1.0)
## Colour of the slot.
@export var colour: Color = default_colour

const default_icon_path = ""
## Icon of the slot.
@export var icon: Texture2D = null
## EditorIcon path of the slot's icon.
@export_dir var icon_path: String = default_icon_path

const list__revertable_properties: Array[StringName] = [
    "connection_category", "colour", "icon_path"
]

func _init(
    index: int,
    location: SlotLocation,
    connection_category: int = self.default_connection_category,
    colour: Color = self.default_colour,
    icon_or_path = null
) -> void:
    self.index = index
    self.location = location
    self.connection_category = connection_category
    self.colour = colour

    if icon_or_path != null and icon_or_path != "":
        if    icon_or_path is Texture2D: self.icon = icon_or_path
        elif  icon_or_path is String: self.icon_path = icon_or_path
        else: push_error(str("Should not init GraphNodeSlotInfo's icon_or_path with type \"", icon_or_path.get_class(), "\""))

func _to_string() -> String:
    var icon_info := ""
    if self.icon != null: icon_info = str(self.icon)
    if self.icon_path != "": icon_info = self.icon_path

    var appending = str(
        "" if self.connection_category == 0 else str("connection_category: ", self.connection_category, ", "),
        "" if self.colour == self.default_colour else str("colour: ", self.colour, ", "),
        "" if self.colour == self.default_colour else str("colour: ", self.colour, ", "),
        icon_info
    )

    return str(
        "GraphNodeSlotInfo@{",
        "index: ", self.index, ", ",
        "location: \"", SlotLocation.find_key(self.location), "\"",
        ", " if appending.length() > 0 else "",
        "}"
    )

## The [code]in[/code] slot should always be the first.
static func createPathInSlot():
    return GraphNodeSlotInfo.new(
        0, SlotLocation.left
    )
