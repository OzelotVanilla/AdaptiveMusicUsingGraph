class_name AMUGResource
extends Resource
## Definition of the music graph `tres` file.
# End of class document.

@export var music_graph: MusicGraph

func _init(music_graph: MusicGraph = MusicGraph.new()) -> void:
    self.music_graph = music_graph
    #self.music_graph = MusicGraph.new(
        #[
            #MusicNode.new(1,"Test1", null, null, Vector2(10,10), [
                #GraphNodeSlotInfo.new(0, GraphNodeSlotInfo.SlotLocation.right)
            #])
        #]
    #)
