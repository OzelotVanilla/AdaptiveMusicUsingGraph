@tool
class_name MusicGraphEditorShortcutManager
extends Object

var save_shortcut = util.getKeyPressShortcutFromText("Ctrl/Command+S")
var close_shortcut = util.getKeyPressShortcutFromText("Ctrl/Command+W")

## Handle the unhandled shortcut from others (e.g., menu bar)
func handle(editor: MusicGraphEditor, event: InputEvent):
    if event.is_echo() or (not event.is_pressed()): return
