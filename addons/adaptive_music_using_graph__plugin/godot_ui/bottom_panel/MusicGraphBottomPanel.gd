@tool
class_name MusicGraphBottomPanel
extends MarginContainer

var slot_control_panel_button: SlotControlPanelButton:
    get: return $VBoxContainer/SlotControlPanelButton
var slot_control_bar: SlotControlBar:
    get: return $VBoxContainer/ScrollContainer/SlotControlBar
var slot_scroll_container: ScrollContainer:
    get: return $VBoxContainer/ScrollContainer

func _ready() -> void: return self.__onReady__()
func _notification(what: int) -> void: return self.__onNotification__(what)

func __onReady__():
    self.slot_control_panel_button.initButtons(self.slot_control_bar)

func __onNotification__(reason):
    match reason:
        Control.NOTIFICATION_THEME_CHANGED:
            self.__prepareTheme__()

func __prepareTheme__():
    self.slot_scroll_container.add_theme_stylebox_override(
        "panel",
        get_theme_stylebox("panel", "Tree")
    )

## Connected in [code]plugin.gd[/code].
func on_GraphEditor_NodeSelectStatusChanged(selected_nodes_set: Dictionary[MusicGraphNode, Variant]):
    if selected_nodes_set.size() == 1:
        self.slot_control_bar.generateControlFromNode(selected_nodes_set.keys()[0])
    else:
        self.slot_control_bar.clear()

## Connected in [code]plugin.gd[/code].
func on_GraphEditor_SelectedNodeHadChanging(selected_nodes_set: Dictionary[MusicGraphNode, Variant]):
    return self.on_GraphEditor_NodeSelectStatusChanged(selected_nodes_set)
