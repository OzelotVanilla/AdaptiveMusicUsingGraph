@tool
class_name SlotControl
extends VBoxContainer

var slot__stored: StrategySlot

var title: Label:
    get: return $Title

func _notification(what: int) -> void: return self.__onNotification__(what)

## Since this scene would be called by [code]PackedScene::instantiate[/code],
##  so all params are set to optional.
func _init(slot: StrategySlot = null) -> void:
    # Data.
    if slot != null:
        self.slot__stored = slot

    # UI.
    self.add_theme_constant_override("separation", 4 * util.editor_scale)
    self.loadUIFromStorage() # If possible.

## Try load from the UI info.
## Abort when [code]self.slot__stored[/code] is null.[br]
## Can reset the [code]self.slot__stored[/code] by param [param slot].
func loadUIFromStorage(slot: StrategySlot = null):
    # Try set and Try load.
    if slot != null: self.slot__stored = slot
    if self.slot__stored == null: return

    # Load.
    self.title.text = self.slot__stored.type__description

func __onNotification__(reason):
    match reason:
        Control.NOTIFICATION_DRAW:
            # Give a different background colour than the panel.
            self.draw_style_box(
                get_theme_stylebox("panel", "TabContainer"),
                Rect2(Vector2(), self.size)
            )
