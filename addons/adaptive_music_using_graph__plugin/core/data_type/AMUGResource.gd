class_name AMUGResource
extends Resource
## Definition of the music graph `tres` file.
# End of class document.

@export var music_graph: MusicGraph

## Optional template for the mock game env.
@export var mock_env_template: AMUGGameEnv = null

func _init(
    music_graph: MusicGraph = MusicGraph.new(),
    mock_env_template: AMUGGameEnv = null
) -> void:
    self.music_graph = music_graph
    self.mock_env_template = mock_env_template

func _to_string() -> String: return self.toString()

func toString():
    return str(
        "AMUGResource@{",
        "resource_path: \"", self.resource_path, "\", ",
        "music_graph: ", self.music_graph,
        "}"
    )
