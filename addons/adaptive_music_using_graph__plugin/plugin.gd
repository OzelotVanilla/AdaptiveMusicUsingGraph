@tool
class_name AdaptiveMusicUsingGraph
extends EditorPlugin

func _enter_tree() -> void: self.__onEnteringSceneTree__()
func _exit_tree() -> void: self.__onExitingSceneTree__()
func _has_main_screen() -> bool: return true
func _get_plugin_name() -> String: return self.panel_tab__name
func _make_visible(visible: bool) -> void: self.setVisibility(visible)
func setVisibility(value: bool): if self.music_graph_main_panel != null: self.music_graph_main_panel.visible = value
func _get_plugin_icon() -> Texture2D:
    return EditorInterface.get_editor_theme().get_icon("CanvasLayer", "EditorIcons")

var music_graph_main_panel_scene = preload("res://addons/adaptive_music_using_graph__plugin/godot_ui/MusicGraphMainPanel.tscn")
var music_graph_main_panel: MusicGraphMainPanel
const tool_menu__name := "Open Music Graph Editor"
const panel_tab__name := "MusicGraphEditor"

func __onEnteringSceneTree__():
    self.music_graph_main_panel = self.music_graph_main_panel_scene.instantiate()
    EditorInterface.get_editor_main_screen().add_child(self.music_graph_main_panel)
    self.setVisibility(false)

func __onExitingSceneTree__():
    if self.music_graph_main_panel != null:
        self.music_graph_main_panel.queue_free()

func onOpenEditor():
    self.music_graph_main_panel.show()
