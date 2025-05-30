@tool
class_name AdaptiveMusicUsingGraph
extends EditorPlugin

func _enter_tree() -> void: return self.__onEnteringSceneTree__()
func _exit_tree() -> void:  return self.__onExitingSceneTree__()
func _has_main_screen() -> bool:      return true
func _get_plugin_name() -> String:    return self.panel_tab__name
func _get_plugin_icon() -> Texture2D: return util.getEditorIcon("CanvasLayer")
func _handles(object: Object) -> bool:     return object is AMUGResource
func _edit(object: Object) -> void:        return self.music_graph_main_panel.handleEditRequestOf(object)
func _make_visible(visible: bool) -> void: return self.setVisibility(visible)

var music_graph_main_panel_scene = preload("res://addons/adaptive_music_using_graph__plugin/godot_ui/MusicGraphMainPanel.tscn")
var music_graph_main_panel: MusicGraphMainPanel
const tool_menu__name := "Open Music Graph Editor"
const panel_tab__name := "MusicGraphEditor"

const file_suffix = ".amug"

#region For modifying editor existing functionality.
var filesystem_popup_helper : FileSystemCreateNewHelper
#endregion

func setVisibility(value: bool):
    if self.music_graph_main_panel != null:
        self.music_graph_main_panel.visible = value

func __onEnteringSceneTree__():
    self.music_graph_main_panel = self.music_graph_main_panel_scene.instantiate()
    EditorInterface.get_editor_main_screen().add_child(self.music_graph_main_panel)
    self.setVisibility(false)

    # Register "New MusicGraph" option to FileSystem's right-click menu.
    self.filesystem_popup_helper = FileSystemCreateNewHelper.new()
    self.add_context_menu_plugin(
        EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM_CREATE,
        self.filesystem_popup_helper
    )

func __onExitingSceneTree__():
    if self.music_graph_main_panel != null:
        self.music_graph_main_panel.queue_free()
    if self.filesystem_popup_helper != null:
        self.remove_context_menu_plugin(self.filesystem_popup_helper)
