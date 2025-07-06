@tool
class_name SoundPlayManager
extends Node
## Manage how sound should be played.
##
## Accept music graph and game param, and decide the play path.
# End of class document.


## Emit when the playing of the current graph is finished.
## Provide the infomation whether it is played in runtime or not.
signal play_finished(is_runtime: bool)

## Reference of the music graph being played.[br][br]
##
## Should be set by [method loadMusicGraph].
var graph_ref: MusicGraph = null

## Reference of the runtime environment.[br][br]
##
## Should be set by [method loadGameEnv].
var env_ref: AMUGGameEnv = null

## Check if currently runs in runtime, or debugtime.
var is_runtime: bool:
    get: return not Engine.is_editor_hint()

## The sound player corresponding to the execute environment
##  (according to whether runtime or not).
var sound_player: AudioStreamPlayer:
    get: return self.__runtime__sound_player if self.is_runtime else self.__debugtime__sound_player
## This is used for storing only. Use [member sound_player] instead.
var __runtime__sound_player: AudioStreamPlayer
## This is used for storing only. Use [member sound_player] instead.
var __debugtime__sound_player: AudioStreamPlayer

func _ready() -> void: return self.__onReady__()
func _process(delta: float) -> void: return self.__onProcess__(delta)

## Load new music graph for sound playing.
func loadMusicGraph(graph: MusicGraph):
    self.graph_ref = graph

## Load new game env for sound playing.
func loadGameEnv(env: AMUGGameEnv):
    self.env_ref = env

## Play the graph.[br][br]
##
## Should provide both [MusicGraph] and [AMUGGameEnv] before run.
## Otherwise, [constant Error.ERR_UNCONFIGURED] will be returned.
func play() -> Error:
    if self.graph_ref == null or self.env_ref == null: return Error.ERR_UNCONFIGURED

    #TODO Use node and edge to play more.
    var starting_node := self.graph_ref.starting_node
    if starting_node == null: return Error.ERR_DOES_NOT_EXIST

    self.resetPlayLoop()
    self.startPlayLoop(starting_node)

    return Error.OK

## Pause the playing.
func pause():
    pass

## Stop the playing.
func stop():
    self.sound_player.stop()
    self.resetPlayLoop()

#region Play loop related.
## To control if [method startPlayLoop] continues looping.
var loop_should_continue: bool = false

## The node being played now.
var current_node: MusicNode = null

## If current loop has a determined play-next. Could be play next node, or just stop (when [code]null[/code]).
var has_next_node_decided: bool = false

## The last time processed in the [method processPlayLoop].
var current_time: float = 0.0

## At which time before the segment stop, should the node be evaluated, and get next node to play.
var time_of_eval_before_stop: float = 0.5

## When the [member current_time] bigger than this value, evaluation of node should start.
var timing_of_eval: float = 0.0

## Reset the play loop to init status.
func resetPlayLoop():
    self.current_node = null
    self.current_time = 0.0
    self.timing_of_eval = 0.0
    self.has_next_node_decided = false
    self.loop_should_continue = false

## Start the graph playing loop from given [param node].[br][br]
##
## [param node] should not be [code]null[/code], and it will be used as the node playing and evaluating.
## [member loop_should_continue] is [code]false[/code] cause the loop stop.
func startPlayLoop(node: MusicNode):
    # If node invalid.
    if node == null:
        push_error("performPlayLoop: Got null for param node.")
        self.resetPlayLoop()
        return
    # If no music.
    if node.music_segment == null:
        push_error("performPlayLoop: Got node with no music segment.")
        self.resetPlayLoop()
        return

    # Load and play.
    self.loop_should_continue = true
    self.current_node = node
    self.current_time = 0.0
    self.has_next_node_decided = false
    self.sound_player.stream = node.music_segment
    self.sound_player.play()

    # Calculate at which time should the node be evaluated.
    ## Sound segment's length in seconds.
    var sound_length := node.music_segment.get_length()
    self.timing_of_eval = max(sound_length - self.time_of_eval_before_stop, 0.0)
    if self.timing_of_eval <= 0.0:
        # This may generate gapping of sound.
        push_warning("performPlayLoop: MusicNode \"", node.name, "\" is too short before getting evaled.")

## Should be called by [method _process] to handle the play-next node.
func processPlayLoop(delta: float):
    # If should stop loop.
    if not self.loop_should_continue:
        self.resetPlayLoop()
        return

    if self.current_node != null:
        self.current_time += delta

    # If does not have next node, and should evaluate now.
    if not self.has_next_node_decided and self.current_time >= self.timing_of_eval:
        var next_edge := self.current_node.evaluate(self.env_ref)
        var next_node := self.graph_ref.getNode(next_edge.to_node) if next_edge != null else null
        # If no available node, make it be ready to stop.
        if next_edge == null or next_node == null:
            self.sound_player.finished.connect(
                func():
                    self.play_finished.emit(self.is_runtime)
                    self.resetPlayLoop(),
                ConnectFlags.CONNECT_ONE_SHOT
            )
        # If available, play that for the next loop.
        else:
            self.sound_player.finished.connect(
                self.startPlayLoop.bind(next_node),
                ConnectFlags.CONNECT_ONE_SHOT
            )
        # Anyway, this makes the next_node decided.
        self.has_next_node_decided = true
#endregion

func __onReady__():
    if self.is_runtime:
        self.__runtime__sound_player = AudioStreamPlayer.new()
        self.add_child(self.__runtime__sound_player)
    else:
        self.__debugtime__sound_player = AudioStreamPlayer.new()
        self.add_child(self.__debugtime__sound_player)

func __onProcess__(delta: float):
    # If there are node being played, process the play loop.
    if self.current_node != null:
        # If first time enter this function, set the current time align with
        if self.current_time <= 0.0:
            self.current_time = self.sound_player.get_playback_position()
        self.processPlayLoop(delta)
