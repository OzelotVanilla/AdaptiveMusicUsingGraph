# Runtime class. DO NOT put `@tool` here.
class_name AMUGRuntime
extends Node
## Runtime logic and API.
##
## Registered as [code]amug[/code] by default to global scope (singleton).
## Responsibility:[br]
## * Receiving game param, provide play status.[br]
# End of class document.


var game_env: AMUGGameEnv = AMUGGameEnv.new()

var music_graph_ref: MusicGraph:
    set(new_graph):
        sound_manager.loadMusicGraph(new_graph)
        music_graph_ref = new_graph

var sound_manager: SoundPlayManager = SoundPlayManager.new()

func _ready() -> void: self.__onReady__()


func recordStatus(game_status: StringName):
    if game_status not in game_env.status__set.keys():
        push_error("Status \"", game_status, "\" not registered.")
        return

    self.game_env.current_status = game_status

func recordPlayerArea(area_name: StringName):
    self.game_env.recordPlayerArea(area_name)

#region Sound play related
## Start new play. See [method SoundPlayManager.play].
func play():
    self.sound_manager.play()
#endregion

func __onReady__():
    self.sound_manager.loadGameEnv(self.game_env)
    self.add_child(self.sound_manager)
