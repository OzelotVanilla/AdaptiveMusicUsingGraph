class_name AMUGGameEnv
extends Resource
## Record the runtime game environment.
##
## Used for [MusicNode] or [StrategySlot] for next-edge evaluation.
# End of class document.

## The user-defined variables.
@export var variables: Dictionary[StringName, Variant] = {}

## Set of all available game status.
@export var status: Dictionary[StringName, Variant] = {}

## Current game status.
@export var current_status: StringName = ""
