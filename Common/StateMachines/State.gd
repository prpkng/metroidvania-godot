@tool
@icon("res://Common/StateMachines/icons/state_icon.svg")
@abstract
class_name State
extends Node
## The base implementation of a FSM State [br][br]

@warning_ignore("unused_signal") signal entered
@warning_ignore("unused_signal") signal exited

## The parent state machine
var machine: StateMachine

func _ready() -> void:
	# Manually call process from owner
	process_mode = Node.PROCESS_MODE_DISABLED

## Called when the owning machine switches to this state
@abstract 
func enter(_args := []) -> void 

pass # This ensures godot don't panic and copies the documentation below with autocompletion

## Called every frame by the owning machine
## [param delta] The delta time
@abstract
func process(delta: float) -> void

pass

## Called every physics frame by the owning machine
## [param delta] The physics delta time
@abstract
func physics_process(delta: float) -> void

pass

## Called when an action is sent by the owning machine
## [param action] The name of the action triggered
## [param args]
@warning_ignore('unused_parameter')
func on_action(action: StringName, ...args: Array) -> void:
	pass
	

## Called by the owning machine just before switching from this state
@abstract
func exit() -> void


func get_full_hierarchy() -> String:
	if machine.machine == null:
		return name
		
	
	var current_name := name
	var state := machine
	while state.machine != null:
		current_name = "%s/%s" % [state.name, current_name]
		state = state.machine
	
	return current_name
	

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if get_parent() is not StateMachine:
		warnings.push_back("A state will only process if owned by a State Machine!")
		
	if get_children(true).size():
		warnings.push_back("States cannot have children! Use a StateMachine instead")
	
	return warnings
