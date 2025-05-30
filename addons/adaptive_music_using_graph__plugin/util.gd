@tool
class_name util
extends RefCounted

#region Editor UI/Theme related
## Get Godot's icon.
## Call it after the editor is ready.
static func getEditorIcon(name: StringName):
    return EditorInterface.get_editor_theme().get_icon(name, "EditorIcons")

static func stringifyPopupMenu(menu: PopupMenu, indent_level: int = 0):
    var result := PackedStringArray()

    for i in range(menu.item_count):
        var submenu := menu.get_item_submenu_node(i)
        # Check if submenu.
        if submenu != null:
            result.append(stringifyPopupMenu(submenu, indent_level + 1))
        else:
            result.append(str(" ".repeat(indent_level), menu.get_item_text(i)))

    return "".join(result)
#endregion

#region Screen related
static var editor_scale: float: get = getEditorScale

static func getEditorScale(): return EditorInterface.get_editor_scale()

static func getEditorScaledSize(from_vec: Vector2):
    return from_vec * EditorInterface.get_editor_scale()
#endregion
