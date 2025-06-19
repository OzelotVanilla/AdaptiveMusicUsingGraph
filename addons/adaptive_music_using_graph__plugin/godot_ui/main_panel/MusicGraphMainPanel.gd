@tool
class_name MusicGraphMainPanel
extends MarginContainer

@onready var graph_editor: MusicGraphEditor = $VBoxContainer/HSplit/EditorAndBreif/MusicGraphEditor
@onready var top_button_bar: TopButtonBar = $VBoxContainer/TopButtonBar
@onready var search_bar: LineEdit = $VBoxContainer/HSplit/FileTabAndParamList/FileTab/Search
@onready var file_tab: FileTabList = $VBoxContainer/HSplit/FileTabAndParamList/FileTab/FileTabList

func _ready() -> void: return self.__onReady__()

func __onReady__():
    self.top_button_bar.initButtons.bind(graph_editor).call_deferred()

func handleEditRequestOf(object: Object):
    if object is AMUGResource:
        # The load of graph should be done in FileTabList.
        # And it should be switched-to (second param).
        self.file_tab.open(object, true)

#region For two panel communication (bridging).
## Connected in [code]plugin.gd[/code].
signal graph_editor__node_select_status_changed(selected_nodes_set: Dictionary[MusicGraphNode, Variant])

## Connected in [code]plugin.gd[/code].
signal graph_editor__selected_node_had_changing(selected_nodes_set: Dictionary[MusicGraphNode, Variant])

## Connected in [code]plugin.gd[/code].
signal graph_editor__node_slot_being_clicked(node: MusicGraphNode, slot: StrategySlot)

## Only used for bridging the signal.
func on_GraphEditor_NodeSelectStatusChanged(selected_nodes_set: Dictionary[MusicGraphNode, Variant]):
    self.graph_editor__node_select_status_changed.emit(selected_nodes_set)

## Only used for bridging the signal.
func on_GraphEditor_SelectedNodeHadChanging(selected_nodes_set: Dictionary[MusicGraphNode, Variant]):
    self.graph_editor__selected_node_had_changing.emit(selected_nodes_set)

func on_GraphEditor_NodeSlotBeingClicked(node: MusicGraphNode, slot: StrategySlot):
    self.graph_editor__node_slot_being_clicked.emit(node, slot)
#endregion
