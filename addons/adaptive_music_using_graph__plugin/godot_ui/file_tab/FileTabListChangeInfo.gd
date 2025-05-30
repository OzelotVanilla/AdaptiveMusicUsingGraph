class_name FileTabListChangeInfo
extends RefCounted

var size: int

static func from(list: FileTabList) -> FileTabListChangeInfo:
    var result = FileTabListChangeInfo.new()
    result.size = list.item_count
    return result
