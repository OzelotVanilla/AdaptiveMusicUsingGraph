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
        self.file_tab.open(object)
