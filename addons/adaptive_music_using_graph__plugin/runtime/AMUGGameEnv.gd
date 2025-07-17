class_name AMUGGameEnv
extends Resource
## Record the runtime game environment.
##
## Used for [MusicNode] or [StrategySlot] for next-edge evaluation.
## All algorithm takes the data got from the time the last [MusicNode] is played,
## called as a [i]period[/i]. [br][br]
##
## Members are exported for saving purpose (mock env).
# End of class document.


## The user-defined variables and its value.
@export var variables: Dictionary[StringName, Variant] = {}

## Set of all available game status.
@export var status__set: Dictionary[StringName, Variant] = {}

## Current game status.
@export var current_status: StringName = ""

## Current player calculated area.
@export var current_area: StringName = ""

## Available algorithm for detecting if there are area change.
enum AreaChangeDetectAlgorithm
{
    ## Use the latest area info.
    latest,
    ## Use the latest area change. Stay in buffer zone is not considered as area change.
    latest_change,
    ## Use the most stayed area of player as the area for this period.
    most_stayed_area,
}

## The algorithm used for detecting if there are area change.
@export var algorithm__area_change: AreaChangeDetectAlgorithm = AreaChangeDetectAlgorithm.latest

## The realtime recording of area data.
## Used to calculate the player's position when [member algorithm__area_change] is set to [enum AreaChangeDetectAlgorithm].
var area_record_dict: Dictionary[StringName, int] = {}


## Clear the time-dependent data.[br][br]
##
## Should be called when new [MusicNode] starts playing to clear the old data got from last period.
func clearHistory():
    self.area_record_dict.clear()

## Record the area information of player.
func recordPlayerArea(area_name: StringName):
    # TODO Not finished.
    match self.algorithm__area_change:
        AreaChangeDetectAlgorithm.latest:
            self.current_area = area_name
