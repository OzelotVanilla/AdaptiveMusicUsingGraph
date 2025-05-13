@tool
class_name MusicGraphMainPanel
extends MarginContainer

@onready var graph_editor: MusicGraphEditor = $VBoxContainer/HSplit/EditorAndBreif/MusicGraphEditor
@onready var top_button_bar: TopButtonBar = $VBoxContainer/MarginContainer/TopButtonBar

func _ready() -> void: self.__onReady__()

func __onReady__():
    top_button_bar.initButtons(graph_editor)
