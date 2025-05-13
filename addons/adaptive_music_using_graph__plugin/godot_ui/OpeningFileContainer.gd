@tool
class_name OpeningFileContainer
extends VBoxContainer

func _ready() -> void:
    #self.__onReady__()
    call_deferred("__onReady__")

func __onReady__():
    var search_box: LineEdit = $Search
    search_box.right_icon = EditorInterface.get_editor_theme().get_icon("Search", "EditorIcons")
