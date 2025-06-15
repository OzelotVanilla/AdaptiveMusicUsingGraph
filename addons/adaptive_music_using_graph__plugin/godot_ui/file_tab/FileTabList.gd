@tool
class_name FileTabList
extends ItemList
## Managing the opening tab of file
##
# End of class document.

## Emit when there is change (add/select/change/remove) in the list.[br]
## The top level abstraction like `open` or `close` should emit it,
##  instead of using the impl func like `addTab`.
signal file_tab_list_changed(info: FileTabListChangeInfo)

## Emit when the opening file is changed.
## The index of the tab, and the file itself will be emitted.
signal opening_file_switched(index: int, file: AMUGResource)

var file_index_dict: Dictionary[AMUGResource, int] = {}

var selected_files: Array[AMUGResource]:
    get:
        var result: Array[AMUGResource] = []
        for index in self.get_selected_items():
            result.append(self.file_index_dict.find_key(index))

        return result


## Open an AMUG resource file. [br]
## Return the index of opened file.
func open(file: AMUGResource) -> int:
    ## The index to select.
    var index: int

    # See if a file is not-yet opened and presented in file tab.
    if self.file_index_dict.has(file):
        index = self.file_index_dict.get(file)
    else:
        index = self.addTab(file)
        self.file_index_dict.set(file, index)

    self.file_tab_list_changed.emit(FileTabListChangeInfo.from(self))
    return index

## Change current opening tab to another.[br]
## Since this method only switch to one tab, previous selected tab will be deselected first.
func switchToTabAt(index: int):
    self.deselect_all()
    self.select(index)
    self.opening_file_switched.emit(self.file_index_dict.find_key(index))
    self.file_tab_list_changed.emit(FileTabListChangeInfo.from(self))

## Close a file and remove it from the tab list.
func closeSelectedTab():
    if not self.is_anything_selected(): return

    var selected_tab = self.get_selected_items()
    for i in selected_tab:
        self.remove_item(i)
        self.file_index_dict.erase(self.file_index_dict.find_key(i))

    self.file_tab_list_changed.emit(FileTabListChangeInfo.from(self))

## Return the index of new tab.
## file_tab_list_changed should not be emitted here.
func addTab(file: AMUGResource):
    var file_name = file.resource_path.get_file().trim_suffix(".tres")
    return self.add_item(file_name, util.getEditorIcon("CanvasLayer"))

## mouse_button_index: 1 is left, 2 is right.
func onFileTabClicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
    # TODO
    match mouse_button_index:
        # If left click, switch to file
        1: self.switchToTabAt(index)
        # TODO: If right click, show menu
        2: pass

## Called when created new file from editor.
## Immediately open and switch to the new file.
func onEditorFinishedCreatingNewFile(path: StringName) -> void:
    var opened_index = self.open(ResourceLoader.load(path))
    self.switchToTabAt(opened_index)
