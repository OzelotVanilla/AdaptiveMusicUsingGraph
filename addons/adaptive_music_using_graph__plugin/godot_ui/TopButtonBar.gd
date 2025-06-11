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
         {"item_name": "New Adaptive Music Graph...", "item_icon": "CanvasLayer", "shortcut": "Command/Ctrl+N",
          "on_press": "onCreatingNewFileAction"},
         {"node_type": "HSeparator"},
         {"item_name": "Save", "item_icon": "Save", "shortcut": "Command/Ctrl+S",
          "on_press": "onSavingAction"},
         {"node_type": "HSeparator"},
         {"item_name": "Close", "item_icon": "Close", "shortcut": "Command/Ctrl+W",
          "on_press": "onClosingAction"},
      ],
     },

    {"node_type": "VSeparator"},

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

    {"name": "Add New In-Out-Slot", "toggle_mode": false, "is_selected": false,
     "on_press": "onAddInOutSlotPress",
     "icon_name": "InsertBefore", "shortcut": "i",
     "description": "Adding new input-then-output slot to a node. This slot is not evaluated if cursor got in from main input slot."},

    {"name": "Add New Out-Slot", "toggle_mode": false, "is_selected": false,
     "on_press": "onAddOutSlotPress",
     "icon_name": "InsertAfter", "shortcut": "o",
     "description": "Adding new output-only slot to a node. This slot will be evaluated together with others when cursor got in from main input slot."},

]

var graph_editor: MusicGraphEditor
## Map popup item (by id) to callback (StringName of method in MusicGraphEditor)[br]
## Since Godot use `id_pressed` for the popup, so need to store these info.
var menu_button_callback_dict: Dictionary[int, StringName]

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
        if config.has("node_type"):
            match config["node_type"]:
                "VSeparator":
                    self.add_child(VSeparator.new())

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

        # For detecting if it is for *editor*, or for *menu*.
        button.name = str("editor_button__", config["name"])
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

## template:
##     {"node_type":"MenuButtton",
##      "button_name": "File",
##      "items": [
##          {"item_name": "Save", "item_icon": "Save", "shortcut": "Command/Ctrl+S",
##           "on_press": "onSaveAction"},
##      ],
##     }
func addMenuButton(config: Dictionary):
    var menu_button := MenuButton.new()
    var popup := menu_button.get_popup()
    popup.clear()

    menu_button.text = config["button_name"]

    # For detecting if it is for *editor*, or for *menu*.
    menu_button.name = str("menu_button__", config["button_name"])

    # Add the item in popup menu.
    var id_counter = 1
    for item in config["items"]:
        if item.has("node_type"):
            match item["node_type"]:
                "HSeparator": popup.add_separator()

            continue

        var item_id = id_counter
        id_counter += 1
        popup.add_icon_item(
            util.getEditorIcon(item["item_icon"]),
            item["item_name"],
            item_id
        )
        var item_index = popup.get_item_index(item_id)

        # Set shortcut.
        popup.set_item_shortcut(
            item_index,
            util.getKeyPressShortcutFromText(item["shortcut"]),
            true
        )
        self.menu_button_callback_dict.set(item_id, item["on_press"])

    # Use separate member variable (dict) and method to handle on_press callback.
    popup.id_pressed.connect(self.handleMenuButtonCallback)

    self.add_child(menu_button)

func handleMenuButtonCallback(id: int):
    var method_name = self.menu_button_callback_dict.get(id)
    if method_name != null:
        self.graph_editor.call_deferred(method_name)

func clear():
    for c in self.get_children():
        self.remove_child(c)

var cache__editor_button_enability: bool = false
func setEnabilityOfEditorButtons(value: bool):
    if value == self.cache__editor_button_enability: return
    self.cache__editor_button_enability = value

    for child in self.get_children(): if child is Button:
        if child.name.begins_with("editor_button__") and child.name not in self.button_enabled_only_when_multiple_node_selected:
            child.disabled = not value

## Called after graph_editor is init-ed.
func onSelectModePress():
    self.graph_editor.operation_mode = MusicGraphEditor.OperationMode.select

## Called after graph_editor is init-ed.
func onMoveModePress():
    self.graph_editor.operation_mode = MusicGraphEditor.OperationMode.move

## Called after graph_editor is init-ed.
func onConnectModePress():
    self.graph_editor.operation_mode = MusicGraphEditor.OperationMode.connect

## Called after graph_editor is init-ed.
func onSingleNodeFocusingModePress():
    self.graph_editor.operation_mode = MusicGraphEditor.OperationMode.single_node_focusing

## Called after graph_editor is init-ed.
func onAddNodePress():
    self.graph_editor.addNode()

## Called after graph_editor is init-ed.
func onAddInOutSlotPress():
    for node in self.graph_editor.selected_nodes_set.keys(): if node is MusicGraphNode:
        node.addInOutSlot()

## Called after graph_editor is init-ed.
func onAddOutSlotPress():
    for node in self.graph_editor.selected_nodes_set.keys(): if node is MusicGraphNode:
        node.addOutSlot()

func onFileTabListChange(info: FileTabListChangeInfo) -> void:
    # If there is no file opened, disable the buttons.
    self.setEnabilityOfEditorButtons(
        info.selected_files.size() == 1
    )

## Record the node name ([code]name[/code]) here.
const button_enabled_only_when_multiple_node_selected: Array[StringName] = [
    "editor_button__Add New In-Out-Slot", "editor_button__Add New Out-Slot"
]

func onSelectingNodeStatusChanged(selected_nodes_set: Dictionary[MusicGraphNode, Variant]) -> void:
    var should_enable_when_multiple_node_selected = selected_nodes_set.size() >= 1
    for button_name in self.button_enabled_only_when_multiple_node_selected:
        var button: Button = self.get_node(NodePath(button_name))
        button.disabled = not should_enable_when_multiple_node_selected
