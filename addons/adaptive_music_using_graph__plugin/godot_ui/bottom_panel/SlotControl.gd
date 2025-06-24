@tool
class_name SlotControl
extends VBoxContainer

var slot__stored: StrategySlot

var title: LineEdit:
    get: return $Title

var eval_type_dropdown: OptionButton:
    get: return $MarginContainer/GridContainer/EvalTypeDropdown

func _notification(what: int) -> void: return self.__onNotification__(what)
func _ready() -> void: return self.__onReady__()

## Since this scene would be called by [code]PackedScene::instantiate[/code],
##  so all params are set to optional.
func _init(slot: StrategySlot = null) -> void:
    # Data.
    if slot != null:
        self.slot__stored = slot

    # UI.
    self.loadUIFromStorage(slot) # If possible.

## Must be called to init the slot information and UI logic.
func init(slot: StrategySlot) -> void:
    self.slot__stored = slot
    self.initTitleLineEdit()
    self.initEvalTypeDropdown()
    self.loadUIFromStorage()

#region UI init.
## The int value of the members in StrategySlot.EvalType, except [code]global_input[/code].
var dropdown_options__eval_type: Array[StrategySlot.EvalType]:
    get:
        var result: Array[StrategySlot.EvalType] = []
        for eval_type in StrategySlot.EvalType.values():
            match eval_type:
                StrategySlot.EvalType.global_input: continue
                StrategySlot.EvalType.through:      continue
                _: result.push_back(eval_type)

        return result

## By default, it is not editable.
## Editable only when being double-clicked.[br]
## Note: For every data-changing action, may better follow with a UI-reload.
func initTitleLineEdit():
    # But for global input, not being able to change.
    if self.slot__stored.type == StrategySlot.EvalType.global_input:
        self.title.tooltip_text = "Global Input cannot be renamed."
    else:
        self.title.tooltip_text = "Double-Click to change name."
        self.title.connect(
            "gui_input",
            func(event: InputEvent):
                if event is InputEventMouseButton:
                    if event.double_click and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
                        self.title.editable = true
                        self.title.grab_focus()
                        self.title.caret_column = self.title.text.length()
        )
        self.title.connect(
            "focus_exited",
            func():
                self.title.editable = false
                # Prevent setting default text to title.
                if self.slot__stored.title != self.title.text:
                    self.slot__stored.title = self.title.text
                self.loadUIFromStorage.call_deferred()
        )
        self.title.connect(
            "text_submitted",
            func(new_text: String):
                self.slot__stored.title = self.title.text
                # Prevent setting default text to title.
                if self.slot__stored.title != self.title.text:
                    self.slot__stored.title = self.title.text
                self.loadUIFromStorage.call_deferred()
        )

func initEvalTypeDropdown():
    var dropdown = self.eval_type_dropdown
    dropdown.clear()

    # If it is global-input, then, cannot change.
    if     self.slot__stored.type == StrategySlot.EvalType.global_input \
      or   self.slot__stored.type == StrategySlot.EvalType.through:
        var type = self.slot__stored.type
        dropdown.add_item(StrategySlot.getTypeReadable(type), type)
        dropdown.select(0)
        dropdown.disabled = true
        dropdown.tooltip_text = str(
            StrategySlot.getTypeDescription(type),
            " Cannot be changed."
        )
    else:
        for eval_type in self.dropdown_options__eval_type:
            dropdown.add_item(StrategySlot.getTypeReadable(eval_type), eval_type)
            var index = dropdown.get_item_index(eval_type)
            dropdown.set_item_tooltip(index, StrategySlot.getTypeDescription(eval_type))
        dropdown.connect(
            "item_selected",
            func(index: int):
                self.slot__stored.type = dropdown.get_item_id(index)
                # If the title is not set yet, need to update title text.
                self.loadUIFromStorage.call_deferred()
        )
#endregion

## Try load from the UI info.
## Abort when [code]self.slot__stored[/code] is null.[br]
## Can reset the [code]self.slot__stored[/code] by param [param slot].
func loadUIFromStorage(slot: StrategySlot = null):
    # Try set and Try load.
    if slot != null: self.slot__stored = slot
    if self.slot__stored == null: return

    # Load.
    self.title.text = self.slot__stored.title
    self.eval_type_dropdown.select(self.eval_type_dropdown.get_item_index(self.slot__stored.type))

func __onReady__():
    self.add_theme_constant_override("separation", 4 * util.editor_scale)
    #self.initTitleLineEdit()
    #self.initEvalTypeDropdown()

func __onNotification__(reason):
    match reason:
        Control.NOTIFICATION_DRAW:
            # Give a different background colour than the panel.
            self.draw_style_box(
                get_theme_stylebox("panel", "TabContainer"),
                Rect2(Vector2(), self.size)
            )
