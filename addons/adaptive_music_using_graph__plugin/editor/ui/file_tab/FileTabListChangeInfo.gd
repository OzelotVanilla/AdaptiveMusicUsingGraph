@tool
class_name FileTabListChangeInfo
extends RefCounted

var size: int
var selected_files: PackedStringArray

static func from(list: FileTabList) -> FileTabListChangeInfo:
    var result = FileTabListChangeInfo.new()

    result.size = list.item_count
    result.selected_files = list.selected_files

    return result

func _to_string() -> String:
    return str(
        "FileTabListChangeInfo@{",
        "size: ", self.size, ", ",
        "selected_files: ", self.selected_files,
        "}"
    )
