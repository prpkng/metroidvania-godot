class_name PlayerGroundStateMachine
extends PlayerMachine

func enter(args := []) -> void:
	super.enter(args)
	
	if "from_air" in args:
		player.animations.play_anim_locking(&"land")
	
	if !player.jump_buffer.is_stopped():
		machine.switch("air", ["jump"])

func physics_process(delta: float) -> void:
	super.physics_process(delta)
	
	if !player.coyote_timer.is_stopped():
		player.coyote_timer.stop()
	
	
	if !player.is_on_floor():
		machine.switch("air")

func on_action(action: StringName, ...args: Array) -> void:
	super.on_action(action, args)
	match action:
		&"jump":
			machine.switch("air", ["jump"])
		&"attack-pressed":
			machine.switch("attack")
			
