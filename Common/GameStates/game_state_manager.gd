class_name GameStateManager
extends Node

signal state_changed(old_state: GameStateBase, new_state: GameStateBase)
signal state_pushed(state: GameStateBase)
signal state_popped(state: GameStateBase)

# State stack: bottom is base state, top is active state
var state_stack: Array[GameStateBase] = []
var registered_states: Dictionary = {}  # state_name -> GameStateBase

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "Game State Manager"

#func _process(delta: float) -> void:
	# Update all visible states (from bottom to top)
	#for state in state_stack:
		#state.process(delta)

#func _physics_process(delta: float) -> void:
	# Update all visible states (from bottom to top)
	#for state in state_stack:
		#state.physics_process(delta)

# Register a state
func register_state(state: GameStateBase) -> void:
	state.state_manager = self
	add_child(state)
	state.process_mode = Node.PROCESS_MODE_DISABLED
	registered_states[state.get_state_name()] = state
	Log.info("Registered state: %s (%s)" % [state.get_state_name(), GameStateBase.StateType.keys()[state.get_state_type()]])

# Change to a new EXCLUSIVE state (clears stack)
func change_state(state_name: String) -> bool:
	if !registered_states.has(state_name):
		Log.error("State not registered: %s" % state_name)
		return false
	
	var new_state: GameStateBase = registered_states[state_name]
	
	# EXCLUSIVE states clear the entire stack
	if new_state.get_state_type() == GameStateBase.StateType.EXCLUSIVE:
		return _change_exclusive_state(new_state)
	else:
		Log.error("Use push_state() for OVERLAY states")
		return false

func _change_exclusive_state(new_state: GameStateBase) -> bool:
	var old_state := get_current_state()
	
	# Exit/cleanup all states in stack
	while state_stack.size() > 0:
		var state := state_stack.pop_back()
		state.process_mode = Node.PROCESS_MODE_DISABLED
		state.exit(new_state)
	
	# Enter new state
	state_stack.append(new_state)
	new_state.enter(old_state)
	
	_update_pause_state()
	state_changed.emit(old_state, new_state)
	
	new_state.process_mode = Node.PROCESS_MODE_ALWAYS
	return true

# Push an OVERLAY state on top of current state
func push_state(state_name: String) -> bool:
	if !registered_states.has(state_name):
		Log.error("State not registered: %s" % state_name)
		return false
	
	var new_state: GameStateBase = registered_states[state_name]
	
	if new_state.get_state_type() != GameStateBase.StateType.OVERLAY:
		Log.error("Can only push OVERLAY states. Use change_state() for EXCLUSIVE states.")
		return false
	
	var previous_top := get_current_state()
	
	# Hide previous top state
	if previous_top:
		previous_top.hide_state()
		previous_top.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Enter new overlay state
	state_stack.append(new_state)
	new_state.enter(previous_top)
	
	_update_pause_state()
	state_pushed.emit(new_state)
	new_state.process_mode = Node.PROCESS_MODE_ALWAYS
	return true

# Pop the top state (return to previous state)
func pop_state() -> bool:
	if state_stack.size() <= 1:
		Log.warn("Cannot pop last state in stack")
		return false
	
	var popped_state = state_stack.pop_back()
	var new_top = get_current_state()
	
	# Exit popped state
	popped_state.exit(new_top)
	
	# Show previous state
	if new_top:
		new_top.show_state()
	
	_update_pause_state()
	state_popped.emit(popped_state)
	return true

# Get current (top) state
func get_current_state() -> GameStateBase:
	if state_stack.size() > 0:
		return state_stack[-1]
	return null

func get_current_state_name() -> String:
	var state = get_current_state()
	return state.get_state_name() if state else "none"

# Get base (bottom) state
func get_base_state() -> GameStateBase:
	if state_stack.size() > 0:
		return state_stack[0]
	return null

# Check if a state is in the stack
func has_state(state_name: String) -> bool:
	for state in state_stack:
		if state.get_state_name() == state_name:
			return true
	return false

# Get state stack depth
func get_stack_depth() -> int:
	return state_stack.size()

func _update_pause_state() -> void:
	# Pause if ANY state in the stack wants pause
	var should_pause = false
	for state in state_stack:
		if state.should_pause_tree():
			should_pause = true
			break
	
	get_tree().paused = should_pause
