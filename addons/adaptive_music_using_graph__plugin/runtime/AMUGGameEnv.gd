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
