@tool
## This class is responsible to maintain the UI and inner data (`graph_store`).
## For each defined method, it should operate on GraphEdit's internal structure to show the UI,
##  and `graph_store: MusicGraph` for saving data.
class_name MusicGraphEditor
extends GraphEdit

var graph_store: MusicGraph

## Add new node.
## Should operate both UI (`self`) and storage (`graph_store: MusicGraph`).
func addNode():
    # TODO
    pass
