# Runtime class. DO NOT put `@tool` here.
class_name AMUGPlayer
extends Node
## Sound player of the Adaptive Music using Graph.
##
## Put this into node tree, and load the music graph to use.
# End of class document.


## The graph going to be played.
@export var music_graph_resource: AMUGResource

func _ready() -> void: self.__onReady__()
func _process(delta: float) -> void: self.__onProcess__(delta)


func __onReady__():
    amug.music_graph_ref = self.music_graph_resource.music_graph
    amug.play()

func __onProcess__(delta: float):
    if amug.game_env == null or amug.music_graph_ref == null:
        return
