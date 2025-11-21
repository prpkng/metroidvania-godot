class_name PlayerAirState
extends PlayerState

var is_jumping := false

func _enter(args := []) -> void:
	player.jump_buffer.stop()
	is_jumping = false
	
	if "jump" in args:
		perform_jump()
	else:
		player.coyote_timer_available = true
		player.coyote_timer.start()
		player.sprite.play_anim(&"air")

func perform_jump() -> void:
	is_jumping = true
	player.velocity.y = player.JUMP_VELOCITY
	player.sprite.play_anim(&"jump")
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	var move_input := player.get_move_input()
	if player.is_on_floor():
		machine.switch(&"ground", ["from_air"])
	
	var gravity := player.GRAVITY if is_jumping else player.FALL_GRAVITY 
	player.velocity.y += gravity * delta
	
	if is_jumping and player.velocity.y > 0:
		is_jumping = false
	
	player.velocity.x = move_toward(
		player.velocity.x, 
		move_input * player.SPEED, 
		(player.ACCELERATION * delta) if move_input != 0 else (player.AIR_FRICTION * delta)
	)

func _on_action(action: StringName, ..._args: Array) -> void:
	if action == &"stop-jump" and is_jumping:
		player.velocity.y *= player.JUMP_CUT_FACTOR
		is_jumping = false
	elif action == &"jump":
		if player.coyote_timer_available:
			perform_jump()
		else:
			player.jump_buffer.start()

func _exit() -> void:
	pass
	
