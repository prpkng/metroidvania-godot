class_name GameStateBase
extends Node

signal state_entered
signal state_exited
signal state_hidden
signal state_shown

var state_manager: GameStateManager

enum StateType {
	EXCLUSIVE,  # Replaces current state completely (MainMenu, Gameplay)
	OVERLAY,    # Runs on top of current state (Pause, Shop, Inventory)
	#PARALLEL    # Runs alongside other states (Background services)
}

# Override these in subclasses
func get_state_name() -> String:
	return "BaseState"

func get_state_type() -> StateType:
	return StateType.EXCLUSIVE

# Called when entering this state for the first time
func enter(previous_state: GameStateBase) -> void:
	Log.info("Entering state: %s (from %s)" % [get_state_name(), previous_state.get_state_name() if previous_state else "none"])
	state_entered.emit()

# Called when completely exiting/cleaning up this state
func exit(next_state: GameStateBase) -> void:
	Log.info("Exiting state: %s (to %s)" % [get_state_name(), next_state.get_state_name()])
	state_exited.emit()
	cleanup()

# Called when state is hidden but kept in memory (for OVERLAY states)
func hide_state() -> void:
	Log.info("Hiding state: %s" % get_state_name())
	state_hidden.emit()

# Called when state is shown again (for OVERLAY states)
func show_state() -> void:
	Log.info("Showing state: %s" % get_state_name())
	state_shown.emit()

# Clean up resources (nodes, connections, etc)
func cleanup() -> void:
	pass

# Can we transition from this state?
func can_exit() -> bool:
	return true

# Should the game tree be paused?
func should_pause_tree() -> bool:
	return false
