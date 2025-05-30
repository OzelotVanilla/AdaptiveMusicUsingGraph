@tool
class_name FileSystemCreateNewHelper
extends EditorContextMenuPlugin

const new_music_graph_dialog_scene := preload("res://addons/adaptive_music_using_graph__plugin/godot_ui/create_new_dialog/NewMusicGraphDialog.tscn")
var new_music_graph_dialog: NewMusicGraphDialog = null

const dialog_min_size = Vector2i(800, 100)

func _popup_menu(paths: PackedStringArray) -> void:
    self.add_context_menu_item(
        "MusicGraph..." if paths.size() > 0 else "New MusicGraph...",
        self.handleCreateNewMusicGraph,
        util.getEditorIcon("CanvasLayer")
    )

func handleCreateNewMusicGraph(paths: PackedStringArray):
    if self.new_music_graph_dialog == null:
        self.new_music_graph_dialog = self.new_music_graph_dialog_scene.instantiate()
        EditorInterface.get_base_control().add_child(self.new_music_graph_dialog)
    self.new_music_graph_dialog.setPathText(paths[0])
    self.new_music_graph_dialog.popup_centered(self.dialog_min_size * util.editor_scale)

func _notification(what: int) -> void:
    # Used to clean the variable inside.
    if what == Object.NOTIFICATION_PREDELETE:
        if self.new_music_graph_dialog != null:
            EditorInterface.get_base_control().remove_child(self.new_music_graph_dialog)
            self.new_music_graph_dialog.queue_free()
