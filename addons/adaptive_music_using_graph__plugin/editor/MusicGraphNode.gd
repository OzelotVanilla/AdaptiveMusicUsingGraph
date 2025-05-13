## This is the class for UI representation in MusicGraphEditor.
## It contains the original MusicNode.
class_name MusicGraphNode
extends GraphNode

var node_store: MusicNode

func updateUIInfoToStore():
    node_store.ui_position = self.position_offset
