@tool
class_name AdaptiveMusicUsingGraph
extends EditorPlugin

func _enter_tree() -> void: return self.__onEnteringSceneTree__()
func _exit_tree() -> void:  return self.__onExitingSceneTree__()
func _has_main_screen() -> bool:      return true
func _get_plugin_name() -> String:    return self.main_panel__tab_title
func _get_plugin_icon() -> Texture2D: return util.getEditorIcon("CanvasLayer")
func _handles(object: Object) -> bool:     return object is AMUGResource
func _edit(object: Object) -> void:        return self.__onReceiveEditRequest__(object)
func _make_visible(visible: bool) -> void: return self.setVisibility(visible)


const tool_menu__name := "Open Music Graph Editor"
const main_panel__tab_title := "MusicGraphEditor"
const bottom_panel__tab_title := "Music Slot"
const file_suffix := ".amug"

#region For UI.
# Note: CANNOT use `@onready` and assignment for the panel.
const music_graph_main_panel_scene := preload("res://addons/adaptive_music_using_graph__plugin/editor/ui/main_panel/MusicGraphMainPanel.tscn")
var music_graph_main_panel: MusicGraphMainPanel = self.music_graph_main_panel_scene.instantiate()
const music_graph_bottom_panel_scene := preload("res://addons/adaptive_music_using_graph__plugin/editor/ui/bottom_panel/MusicGraphBottomPanel.tscn")
var music_graph_bottom_panel: MusicGraphBottomPanel = self.music_graph_bottom_panel_scene.instantiate()
#endregion

#region For modifying editor existing functionality.
var filesystem_popup_helper : FileSystemCreateNewHelper
#endregion

func setVisibility(value: bool):
    if self.music_graph_main_panel != null:
        self.music_graph_main_panel.visible = value

func __onEnteringSceneTree__():
    # Main panel.
    EditorInterface.get_editor_main_screen().add_child(self.music_graph_main_panel)
    self.setVisibility(false)

    # Bottom slot control panel.
    self.add_control_to_bottom_panel(
        self.music_graph_bottom_panel,
        self.bottom_panel__tab_title
    )

    # Register "New MusicGraph" option to FileSystem's right-click menu.
    self.filesystem_popup_helper = FileSystemCreateNewHelper.new()
    self.add_context_menu_plugin(
        EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM_CREATE,
        self.filesystem_popup_helper
    )

    # Connect Main and Bottom panel's necessary signal.
    self.music_graph_main_panel.connect(
        "graph_editor__node_select_status_changed",
        self.music_graph_bottom_panel.on_GraphEditor_NodeSelectStatusChanged
    )
    self.music_graph_main_panel.connect(
        "graph_editor__selected_node_had_changing",
        self.music_graph_bottom_panel.on_GraphEditor_SelectedNodeHadChanging
    )
    self.music_graph_main_panel.connect(
        "graph_editor__node_slot_being_clicked",
        self.music_graph_bottom_panel.on_GraphEditor_NodeSlotBeingClicked
    )

func __onExitingSceneTree__():
    if self.music_graph_main_panel != null:
        self.music_graph_main_panel.queue_free()
    if self.music_graph_bottom_panel != null:
        self.remove_control_from_bottom_panel(self.music_graph_bottom_panel)
        self.music_graph_bottom_panel.queue_free()
    if self.filesystem_popup_helper != null:
        self.remove_context_menu_plugin(self.filesystem_popup_helper)

func __onReceiveEditRequest__(object: Object):
    self.music_graph_main_panel.handleEditRequestOf(object)
    self.make_bottom_panel_item_visible(self.music_graph_bottom_panel)
