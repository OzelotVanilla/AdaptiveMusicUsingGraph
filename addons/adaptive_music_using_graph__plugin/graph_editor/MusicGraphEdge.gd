@tool
class_name MusicGraphEdge
extends Control
## Pseudo UI representation in MusicGraphEditor
##
## This class is created in order to extends the functionality of edge (connection) in GraphEdit. [br]
##
## It overlays with the connection, and should pass all the process (e.g., deletion) to the representing connection.
# End of class document.

var edge_store: MusicEdge
