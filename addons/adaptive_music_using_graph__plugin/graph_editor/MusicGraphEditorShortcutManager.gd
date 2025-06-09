@tool
class_name MusicGraphEditorShortcutManager
extends Object

var save_shortcut = Shortcut.new()
var close_shortcut = Shortcut.new()

func handle(editor: MusicGraphEditor, event: InputEvent):
    if event.is_echo() or (not event.is_pressed()): return

    if   save_shortcut.matches_event(event):
        editor.onSavingAction()
    elif close_shortcut.matches_event(event):
        editor.onClosingAction()

func _init() -> void:
    var ctrl_s_event = InputEventKey.new()
    ctrl_s_event.keycode = OS.find_keycode_from_string("Ctrl/Command+S")
    ctrl_s_event.keycode = Key.KEY_S
    ctrl_s_event.command_or_control_autoremap = true
    ctrl_s_event.pressed = true
    self.save_shortcut.events.append(ctrl_s_event)

    var ctrl_w_event = InputEventKey.new()
    #ctrl_s_event.keycode = OS.find_keycode_from_string("Command/Ctrl+W")
    ctrl_w_event.keycode = Key.KEY_W
    ctrl_w_event.command_or_control_autoremap = true
    ctrl_w_event.pressed = true
    self.save_shortcut.events.append(ctrl_w_event)
