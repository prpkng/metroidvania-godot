class_name PlayerGroundStateMachine
extends PlayerMachine

func _enter(args := []) -> void:
	super._enter(args)
	
	if "from_air" in args:
		player.sprite.play_anim_locking(&"land")
	
	if !player.jump_buffer.is_stopped():
		machine.switch("air", ["jump"])

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if player.coyote_timer_available:
		player.coyote_timer.stop()
	player.coyote_timer_available = false
	
	
	if !player.is_on_floor():
		machine.switch("air")

func _on_action(action: StringName, ...args: Array) -> void:
	super._on_action(action, args)
	if action == &"jump":
		machine.switch("air", ["jump"])
