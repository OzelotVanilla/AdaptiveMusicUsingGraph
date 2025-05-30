@tool
class_name NewMusicGraphDialog
extends ConfirmationDialog

func _ready() -> void: self.__onReady__()

const default_new_name = "new_music_graph"
const folder_select_dialog_min_size = Vector2i(1050, 700)

@onready var path_edit: LineEdit = $VBoxContainer/GridContainer/PathSetting/PathEdit
var folder_select: EditorFileDialog


func __onReady__():
    # Enter in PathEdit confirm the window.
    self.register_text_enter(path_edit)

    # Add folder browsing dialog.
    self.folder_select = EditorFileDialog.new()
    self.folder_select.visible = false
    self.add_child(folder_select)

    # Add "Folder Browsing" button.
    var path_setting = $VBoxContainer/GridContainer/PathSetting
    var button = Button.new()
    button.icon = util.getEditorIcon("Folder")
    button.connect("pressed", self.openFolderBrowser)
    path_setting.add_child(button)

func setPathText(path: String):
    if not path.ends_with("/"): path += "/"
    var new_file_path = str(
        path, self.default_new_name,
        AdaptiveMusicUsingGraph.file_suffix, ".tres"
    )
    self.path_edit.text = new_file_path
    self.path_edit.select(
        new_file_path.rfind("/") + 1,
        # Because there are double-extension, need to be shorter.
        new_file_path.get_basename().length() - AdaptiveMusicUsingGraph.file_suffix.length()
    )
    # First set this to scroll.
    self.path_edit.set_caret_column(new_file_path.length())
    self.path_edit.set_caret_column(new_file_path.rfind("/") + 1)

func onOK():
    var new_file_path = self.path_edit.text
    ResourceSaver.save(AMUGResource.new(), new_file_path)

func openFolderBrowser():
    self.folder_select.visible = true
    self.folder_select.popup_centered(self.folder_select_dialog_min_size * util.editor_scale)

func performPrePopupAction() -> void:
    # Deferring call to make sure the focus is finally grabbed by path_edit.
    self.path_edit.grab_focus.call_deferred()
