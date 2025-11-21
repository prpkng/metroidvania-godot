@icon("res://Common/StateMachines/icons/state_machine_icon.svg")
class_name StateMachine
extends State

## If true, resets the [member _current_state_name] to the [member _start_state_name] at [method enter]
@export var reset_on_enter: bool = true
@export var states: Dictionary[StringName, State]

var _current_state: State = null
var _current_state_name: StringName

var _start_state_name: StringName

func _init(states_dict: Dictionary[StringName, State] = {}) -> void:
	states = states_dict
	if states_dict.size() > 0:
		_start_state_name = states.keys()[0]
	for state_name: StringName in states.keys():
		states[state_name].machine = self
		states[state_name].name = state_name
		

func _enter(_args := []) -> void:
	if _current_state_name == &"" or reset_on_enter:
		_current_state_name = _start_state_name
		_current_state = states[_current_state_name]
	
	_current_state._enter(_args)

func _process(delta: float) -> void:
	_current_state._process(delta)

func _physics_process(delta: float) -> void:
	_current_state._physics_process(delta)

func _exit() -> void:
	_current_state._exit()

## Triggers an action in the state machine. [br][br]
## A collection of optional [param args] can also be passed to the target state's [method State._on_action] [br]
func trigger(action: StringName, args := []) -> void:
	_current_state._on_action(action, args)

## Switches the machine to the given state [br][br]
## A collection of optional [param args] can be passed to the target state's [method State._enter] [br]
func switch(target_state: StringName, args := []) -> void:
	if not target_state in states:
		Log.err("State named '%s' not found in state machine!" % target_state)
		return
	
	if _current_state != null:
		_current_state._exit()
	
	_current_state_name = target_state
	_current_state = states[_current_state_name]
	
	_current_state._enter(args)
	

## Adds a new state to the machine [br][br]
## [b]Note:[/b] The first state added to the machine will be assigned as the [member _start_state_name]  [br]
func add_state(new_name: StringName, new_state: State) -> void:
	if new_name in states:
		Log.err("State named '%s' already exists in state machine!" % new_name)
		return
	
	states[new_name] = new_state
	
	if _start_state_name == null:
		_start_state_name = new_name
	

## Sets the start state for this state machine
func set_start_state(new_name: StringName) -> void:
	if not new_name in states:
		Log.err("Trying to set a start state named '%s' not present in state machine!" % new_name)
		return
	_start_state_name = new_name
	
	
## Returns all states the machine
## If [param recursive] is true, nested machines will also be taken into account
func get_all_states(recursive := false) -> Array[State]:
	if recursive == false:
		return states.values()
	
	var found_states: Array[State] = []
	for state: State in states.values():
		if state is StateMachine:
			found_states.append_array(state.get_all_states(true))
		found_states.push_back(state)
	
	return found_states

## Returns the deepest state in the machine's hierarchy
func get_leaf_state() -> State:
	return _current_state.get_leaf_state() if _current_state is StateMachine else _current_state
