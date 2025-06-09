@tool
class_name FileTabList
extends ItemList
## Managing the opening tab of file
##
# End of class document.


## Emit when the opening file is changed.
## The index of the tab, and the file itself will be emitted.
signal opening_file_switched(index: int, file: AMUGResource)

var file_index_dict: Dictionary[AMUGResource, int] = {}

## Open an AMUG resource file
func open(file: AMUGResource):
    ## The index to select.
    var index: int

    # See if a file is not-yet opened and presented in file tab.
    if self.file_index_dict.has(file):
        index = self.file_index_dict.get(file)
    else:
        index = self.addTab(file)
        self.file_index_dict.set(file, index)

func switchToTabAt(index: int):
    self.select(index)
    self.opening_file_switched.emit(index, self.file_index_dict.find_key(index))

## Return the index of new tab.
func addTab(file: AMUGResource):
    var file_name = file.resource_path.get_file().trim_suffix(".tres")
    return self.add_item(file_name, util.getEditorIcon("CanvasLayer"))

func closeSelectedTab():
    if not self.is_anything_selected(): return

    var selected_tab = self.get_selected_items()
    for i in selected_tab: self.remove_item(i)

## mouse_button_index: 1 is left, 2 is right.
func onFileTabClicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
    # TODO
    match mouse_button_index:
        # If left click, switch to file
        1: self.switchToTabAt(index)
        # If right click, show menu
        2: pass
