@tool
class_name SlotControlPanelButton
extends HBoxContainer

# template for buttons and separator:
#           {"name": "", "toggle_mode": false, "is_selected": false,
#            "on_press": "",
#            "icon_name": "", "shortcut": "", "group": "",
#            "description": ""},
#           {"node_type": "VSeparator"},
## The buttons config of the top button bar.
@onready var top_buttons_config: Array[Dictionary]: get = getTopButtonsConfig

func getTopButtonsConfig():
    return \
[
    {"name": "Go Previous Page", "toggle_mode": false, "is_selected": false,
     "on_press": "onGoPreviousPagePress",
     "icon_name": "PagePrevious", #"shortcut": "n",
     "description": "Go to previous page of slot."},

    {"name": "Go Next Page", "toggle_mode": false, "is_selected": false,
     "on_press": "onGoNextPagePress",
     "icon_name": "PageNext", #"shortcut": "n",
     "description": "Go to next page of slot."},
]

var slot_control_bar: SlotControlBar

## This will be called only if the music graph editor is ready.
func initButtons(slot_control_bar: SlotControlBar):
    # If there are placeholders, clear.
    self.clear()

    # Store reference to fully-loaded music graph editor.
    self.slot_control_bar = slot_control_bar

    # Init buttons according to settings.
    var button_groups: Dictionary[String, ButtonGroup] = {}

    for config in self.top_buttons_config:
        # Add separator or something else than a button.
        if config.has("node_type"):
            match config["node_type"]:
                "VSeparator":
                    self.add_child(VSeparator.new())

            continue

        # Or, add button.
        var button = Button.new()
        button.theme_type_variation = "FlatButton"
        button.focus_mode = Control.FOCUS_CLICK
        button.mouse_exited.connect(func(): button.release_focus())

        button.toggle_mode = config["toggle_mode"]
        button.button_pressed = config["is_selected"]
        button.icon = util.getEditorIcon(config["icon_name"])
        button.pressed.connect(self[config["on_press"]])
        button.name = str("slot_panel_button__", config["name"])

        # And at first, no file tab is opened, so they should be disabled.
        button.disabled = true

        # Add shortcut
        if config.has("shortcut"):
            var shortcut := Shortcut.new()
            var key_event := InputEventKey.new()
            key_event.keycode = OS.find_keycode_from_string(config["shortcut"])
            key_event.pressed = true
            # A name is added before the shortcut indicator (e.g., "(Q)").
            shortcut.resource_name = config["name"]
            shortcut.events.append(key_event)
            button.shortcut = shortcut

        # If button are in one radio button group.
        if config.has("group"):
            var group_name: String = config["group"]
            if not button_groups.has(group_name):
                button_groups[group_name] = ButtonGroup.new()
            button.button_group = button_groups[group_name]

        # If button has detailed description for tooltip.
        if config.has("description"):
            button.tooltip_text = config["description"]

        self.add_child(button)

func clear():
    for c in self.get_children():
        self.remove_child(c)

#region Callback for buttons
func onGoPreviousPagePress():
    pass

func onGoNextPagePress():
    pass
#endregion
