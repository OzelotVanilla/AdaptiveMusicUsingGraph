@tool
class_name ParamList
extends VBoxContainer

const dialog_min_size = Vector2i(1050, 700)

var node_ref: MusicNode
var selected_audio_path_label: Label
var audio_selected: AudioStream
var audio_select_dialog: EditorFileDialog

func _ready() -> void: return self.__onReady__()

#region UI constant.
var message__select_a_node_to_start: Label:
    get:
        var label = Label.new()
        label.size_flags_vertical = Control.SIZE_EXPAND_FILL
        label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
        label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.text = "Select a node to adjust its parameter."
        return label
var message__too_many_node_selected: Label:
    get:
        var label = Label.new()
        label.size_flags_vertical = Control.SIZE_EXPAND_FILL
        label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
        label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.text = "Select only one node to adjust parameter."
        return label

var supported_file_format: PackedStringArray:
    get:
        return PackedStringArray([
            str("*.mp3, *.wav, *.ogg", " ; ", "Supported Audio Files")
        ])
#endregion

func __onReady__():
    # Init the audio select file dialog.
    self.audio_select_dialog = EditorFileDialog.new()
    self.audio_select_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
    self.audio_select_dialog.visible = false
    self.audio_select_dialog.filters = self.supported_file_format
    self.audio_select_dialog.connect("file_selected", self.onAudioFileSelected)
    self.add_child(self.audio_select_dialog, false, Node.INTERNAL_MODE_FRONT)

## Show the setting of node param.
func showSetting(music_node: MusicNode):
    self.clear()
    self.node_ref = music_node

    var load_song__label: Label = Label.new()
    load_song__label.text = "Song to Play"
    self.add_child(load_song__label)

    # File name and select button.
    var file_name_and_select_button__hb = HBoxContainer.new()
    var file_name_label: Label = Label.new()
    file_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    file_name_label.clip_text = true
    self.selected_audio_path_label = file_name_label
    file_name_and_select_button__hb.add_child(file_name_label)

    var load_song__button: Button = Button.new()
    load_song__button.icon = util.getEditorIcon("Folder")
    load_song__button.connect("pressed", self.openFileBrowser)
    file_name_and_select_button__hb.add_child(load_song__button)

    self.add_child(file_name_and_select_button__hb)

    # Load UI info.
    self.loadUIFromNode()

func loadUIFromNode():
    if self.selected_audio_path_label != null:
        if self.node_ref.music_segment_path != "":
            var file_name = self.node_ref.music_segment_path.get_file()
            self.selected_audio_path_label.text = file_name
            self.selected_audio_path_label.tooltip_text = file_name
        else:
             self.selected_audio_path_label.text = "<empty>"

func openFileBrowser():
    self.audio_select_dialog.popup_centered(util.editor_scale * self.dialog_min_size)

func showSelectNodeToStart():
    self.clear()
    self.add_child(self.message__select_a_node_to_start)

func showTooManyNodesSelected():
    self.clear()
    self.add_child(self.message__too_many_node_selected)

func clear():
    self.node_ref = null
    for c in self.get_children():
        self.remove_child(c)
        c.queue_free()

func onSelectingNodeStatusChanged(selected_nodes_set: Dictionary[MusicGraphNode, Variant]) -> void:
    match selected_nodes_set.size():
        0:
            self.showSelectNodeToStart()

        1:
            self.showSetting((selected_nodes_set.keys()[0] as MusicGraphNode).node_store)

        var n when n > 1:
            self.showTooManyNodesSelected()

func onAudioFileSelected(path: String):
    self.node_ref.music_segment_path = path
    self.loadUIFromNode()
