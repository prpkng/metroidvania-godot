@icon("res://Common/StateMachines/icons/state_machine_icon.svg")
class_name FSM
extends Node

@export var root: StateMachine = StateMachine.new()
@export var autostart := false

var _started := false

func start() -> void:
	root._enter()
	_started = true

func _ready() -> void:
	if autostart: start()

func process(delta: float) -> void:
	if _started: root._process(delta)
	pass

func physics_process(delta: float) -> void:
	if _started: root._physics_process(delta)

func _exit_tree() -> void:
	if _started: root._exit()

## Returns all states the machine
## If [param recursive] is true, nested machines will also be taken into account
func get_all_states(recursive := false) -> Array[State]:
	return root.get_all_states(recursive)
