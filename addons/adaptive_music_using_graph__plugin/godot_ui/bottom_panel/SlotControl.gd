@tool
class_name SlotControl
extends VBoxContainer

var slot__stored: StrategySlot

func _notification(what: int) -> void: return self.__onNotification__(what)

func _init(slot: StrategySlot) -> void:
    # Data.
    self.slot__stored = slot

    # UI.
    self.size_flags_vertical = SizeFlags.SIZE_EXPAND_FILL
    self.add_theme_constant_override("separation", 4 * util.editor_scale)

    var title = Label.new()
    title.text = slot.type__description
    self.add_child(title)

func __onNotification__(reason):
    match reason:
        Control.NOTIFICATION_DRAW:
            # Give a different background colour than the panel.
            self.draw_style_box(
                get_theme_stylebox("panel", "TabContainer"),
                Rect2(Vector2(), self.size)
            )
