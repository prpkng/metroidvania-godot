@icon("res://Common/StateMachines/icons/state_icon.svg")
@abstract
class_name State
extends Resource
## The base implementation of a FSM State [br][br]


## The parent state machine
var machine: StateMachine
## The name of this state in the owning machine
var name: String

## Called when the owning machine switches to this state
@abstract 
func _enter(args := []) -> void 

pass # This ensures godot don't panic and copies the documentation below with autocompletion

## Called every frame by the owning machine
## [param delta] The delta time
@abstract
func _process(delta: float) -> void

pass

## Called every physics frame by the owning machine
## [param delta] The physics delta time
@abstract
func _physics_process(delta: float) -> void

pass

## Called when an action is sent by the owning machine
## [param action] The name of the action triggered
## [param args]
@warning_ignore('unused_parameter')
func _on_action(action: StringName, ...args: Array) -> void:
	pass
	

## Called by the owning machine just before switching from this state
@abstract
func _exit() -> void


func get_full_hierarchy() -> String:
	if machine.machine == null:
		return name
	
	var current_name := name
	var state := machine
	while state.machine != null:
		current_name = "%s/%s" % [state.name, current_name]
		state = state.machine
	
	return current_name
		
