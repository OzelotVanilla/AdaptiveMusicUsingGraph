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

#region Shortcut related
static var command_or_ctrl_check: RegEx:
    get: return RegEx.create_from_string("(?i)(?:command/ctrl)|(?:ctrl/command)")
static func getKeyPressShortcutFromText(text: String) -> Shortcut:
    # Code adopt from Godot Channel
    var shortcut = Shortcut.new()
    var event = InputEventKey.new()
    var key = OS.find_keycode_from_string(text)

    # Check if "Command/Ctrl".
    var is_command_or_ctrl := false
    for part in text.split("+"):
        if command_or_ctrl_check.search(part) != null:
            event.command_or_control_autoremap = true
            is_command_or_ctrl = true
            break

    event.pressed = true
    event.keycode = key & KeyModifierMask.KEY_CODE_MASK
    event.shift_pressed = key & KeyModifierMask.KEY_MASK_SHIFT
    event.alt_pressed = key & KeyModifierMask.KEY_MASK_ALT
    if not is_command_or_ctrl:
        event.ctrl_pressed = key & KeyModifierMask.KEY_MASK_CTRL
        event.meta_pressed = key & KeyModifierMask.KEY_MASK_META

    shortcut.events.append(event)
    return shortcut
#endregion
