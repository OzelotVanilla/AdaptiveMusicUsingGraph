class_name AMUGResource
extends Resource
## Definition of the music graph `tres` file.
# End of class document.

@export var music_graph: MusicGraph

func _init(music_graph: MusicGraph = MusicGraph.new()) -> void:
    self.music_graph = music_graph

func _to_string() -> String: return self.toString()

func toString():
    return str(
        "AMUGResource@{",
        "music_graph: ", self.music_graph,
        "}"
    )
