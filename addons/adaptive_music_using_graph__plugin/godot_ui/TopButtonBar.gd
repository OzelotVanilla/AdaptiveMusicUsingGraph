@tool
class_name TopButtonBar
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
    {"node_type":"MenuButtton",
     "button_name": "File",
     "items": [
         {"item_name": "Save", "item_icon": "Save", "shortcut": "Command/Ctrl+S",
          "on_press": "onSavingAction"},
      ],
     },

    {"name": "Select Mode", "toggle_mode": true, "is_selected": true,
     "on_press": "onSelectModePress",
     "icon_name": "ToolSelect", "shortcut": "q", "group": "operation_mode",
     "description": "Selecting node or edge."},

    {"name": "Move Mode", "toggle_mode": true, "is_selected": false,
     "on_press": "onMoveModePress",
     "icon_name": "ToolMove", "shortcut": "w", "group": "operation_mode",
     "description": "Moving node or edge."},

    {"name": "Connect Mode", "toggle_mode": true, "is_selected": false,
     "on_press": "onConnectModePress",
     "icon_name": "Curve2D", "shortcut": "e", "group": "operation_mode",
     "description": "Connect two nodes with edge."},

    {"name": "Single Node Focusing Mode", "toggle_mode": true, "is_selected": false,
     "on_press": "onSingleNodeFocusingModePress",
     "icon_name": "Zoom", "shortcut": "s", "group": "operation_mode",
     "description": "Focus on the selected node, only show its adjacent node and connections."},

    {"node_type": "VSeparator"},

    {"name": "Add New Node", "toggle_mode": false, "is_selected": false,
     "on_press": "onAddNodePress",
     "icon_name": "Add", "shortcut": "n",
     "description": "Adding new music playback node."},
]

var graph_editor: MusicGraphEditor

## This will be called only if the music graph editor is ready.
func initButtons(graph_editor: MusicGraphEditor):
    # If there are placeholders, clear.
    self.clear()

    # Store reference to fully-loaded music graph editor.
    self.graph_editor = graph_editor

    # Init buttons according to settings.
    var button_groups: Dictionary[String, ButtonGroup] = {}

    for config in self.top_buttons_config:
        # Add separator or something else than a button.
        if config.has("node_type"): match config["node_type"]:
            "VSeparator":
                self.add_child(VSeparator.new())
                continue

            "MenuButtton":
                self.addMenuButton(config)
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

## template:
##     {"node_type":"MenuButtton",
##      "button_name": "File",
##      "items": [
##          {"item_name": "Save", "item_icon": "Save", "shortcut": "Command/Ctrl+S",
##           "on_press": "onSaveAction"},
##      ],
##     }
func addMenuButton(config: Dictionary):
    print_debug(config)
    var menu_button := MenuButton.new()
    var popup := menu_button.get_popup()

    menu_button.name = config["button_name"]
    menu_button.text = config["button_name"]
    for item in config["items"]:
        popup.add_icon_item(
            util.getEditorIcon(item["item_icon"]),
            item["item_name"]
        )

    self.add_child(menu_button)

func clear():
    for c in self.get_children():
        self.remove_child(c)

## Called after graph_editor is init-ed.
func onSelectModePress():
    self.graph_editor.operation_mode = MusicGraphEditor.OperationMode.select

## Called after graph_editor is init-ed.
func onMoveModePress():
    self.graph_editor.operation_mode = MusicGraphEditor.OperationMode.move


## Called after graph_editor is init-ed.
func onConnectModePress():
    self.graph_editor.operation_mode = MusicGraphEditor.OperationMode.connect


func onSingleNodeFocusingModePress():
    self.graph_editor.operation_mode = MusicGraphEditor.OperationMode.single_node_focusing

## Called after graph_editor is init-ed.
func onAddNodePress():
    self.graph_editor.addNode()
