@tool
class_name StrategySlot
extends Resource
## Class for storing the after-playing decision for a node.
##
## The [code]PortLocation[/code] is the [i]slot[/i]'s position of Godot.
# End of class document.

## When the MusicGraphNode need to reload UI.
signal slot_changed(slot: StrategySlot)

enum PortLocation
{
    left,
    right,
    both
}

## The evaluation type of the slot.[br][br]
##
## For the in-path connected into main input, the precedence of the evaluation is:[br]
## 1. area_change. If match, produce 100% fitness. [br]
## 2. status_change. If match, produce 100% fitness. [br]
## 3. expression_group.
##    Groups will generate fitness by group-expression first,
##     then if a group is picked, the slot expression will calculate fitness.
##    By default, group-expression provides 100% fitness. [br]
## 4. default. Could be set with a fixed fitness value. [br]
enum EvalType
{
    ## EvalType is not-set-yet.
    none,
    ## For the global input path.
    global_input,
    ## Will be chosen when the player goes to different area.
    area_change,
    ## Will be chosen when the game state is changing to defined state.
    status_change,
    ## Will accept game parameter, and use expression to calculate which route will be chosen.
    expression_group,
    ## The default route when all previous checks yields no chosen route.
    default,
    ## Directly go to this slot's out-path.
    through
}

var type__readable: StringName:
    get(): return StrategySlot.getTypeReadable(type)

var type__description: StringName:
    get(): return StrategySlot.getTypeDescription(type)


## The location of the slot on the node.
@export var location: PortLocation

## How the slot evaluate.
@export var type: EvalType:
    set(value):
        if type == value: return

        type = value
        self.slot_changed.emit(self)

## Title displayed in the slot.
@export var title: StringName = "":
    set(value):
        if title == value: return

        title = value
        self.slot_changed.emit(self)
    get():
        # If no title, return default.
        if title == "":
            match self.type:
                StrategySlot.EvalType.none: return "Eval Type Not Set"
                _:                          return self.type__readable
        else: return title

## Group name if using expression_group as eval method.
@export var group_name: StringName = "":
    set(value):
        if group_name == value: return

        group_name = value
        self.slot_changed.emit(self)
    get():
        if group_name == "": return "default_group"
        else: return group_name

const default_colour = Color(0.7, 0.7, 0.7, 1.0)
## Colour of the slot.
@export var colour: Color = default_colour

const default_icon_path = ""
## Icon of the slot.
@export var icon: Texture2D = null
## EditorIcon path of the slot's icon.
@export_dir var icon_path: String = default_icon_path

const default_connection_category = 0
## `type_left`/`type_right` for the slot. By default, set to 0 in this project.
@export var connection_category: int = default_connection_category


const list__revertable_properties: Array[StringName] = [
    "connection_category", "colour", "icon_path"
]

## [param icon_or_path] could be [Texture2D] for icon itself, or [String] representing for path.
func _init(
    location: PortLocation,
    type: EvalType = EvalType.none,
    title: StringName = "",
    group_name: StringName = "",
    colour: Color = self.default_colour,
    icon_or_path: Variant = null,
    connection_category: int = self.default_connection_category,
) -> void:
    self.location = location
    self.type = type
    self.title = title
    self.group_name = group_name
    self.colour = colour
    self.connection_category = connection_category

    if icon_or_path != null and icon_or_path != "":
        if    icon_or_path is Texture2D: self.icon = icon_or_path
        elif  icon_or_path is String: self.icon_path = icon_or_path
        else: push_error(str("Should not init StrategySlot's icon_or_path with type \"", icon_or_path.get_class(), "\""))

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
        "StrategySlot@{",
        "title: \"", self.title, "\", ",
        "location: \"", PortLocation.find_key(self.location), "\"",
        ", " if appending.length() > 0 else "",
        "}"
    )

static func getTypeReadable(type: StrategySlot.EvalType):
    match type:
        StrategySlot.EvalType.none:
            return "None"

        StrategySlot.EvalType.global_input:
            return "Input"

        StrategySlot.EvalType.area_change:
            return "Area"

        StrategySlot.EvalType.status_change:
            return "Status"

        StrategySlot.EvalType.expression_group:
            return "Expression"

        StrategySlot.EvalType.default:
            return "Otherwise"

        StrategySlot.EvalType.through:
            return "Go-Through"

        _:
            push_error("Unknown member: ", StrategySlot.EvalType.find_key(type), " (", type,").")
            return "Unknown Member"

static func getTypeDescription(type: StrategySlot.EvalType):
    match type:
        StrategySlot.EvalType.none:
            return "No evaluation type. This slot would be out-of evaluation process."

        StrategySlot.EvalType.global_input:
            return "Represents global input."

        StrategySlot.EvalType.area_change:
            return "Let the slot changes according to player's area position."

        StrategySlot.EvalType.status_change:
            return "Let the slot changes according to user-defined game status."

        StrategySlot.EvalType.expression_group:
            return str(
                "Use expression to evaluate.",
                "Assign current slot to a group by name, and give it an evaluate expression."
            )

        StrategySlot.EvalType.default:
            return "If all other slots has low/no fitness, this default slot will be chosen."

        StrategySlot.EvalType.through:
            return "All in-path connected to this slot will skip the evaluation and directly play-and-go."

        _:
            push_error("Unknown member: ", StrategySlot.EvalType.find_key(type), " (", type,").")
            return "Unknown Member"
