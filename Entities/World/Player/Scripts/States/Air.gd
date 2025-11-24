class_name PlayerAirState
extends PlayerState

var was_on_wall := false
var last_wall_dir := 0

var is_jumping := false

func enter(args := []) -> void:
	player.jump_buffer.stop()
	is_jumping = false
	was_on_wall = false
	last_wall_dir = 0
	
	if "already_jumping" in args:
		is_jumping = true
	elif "jump" in args:
		perform_jump()
	elif "wall_jump" in args:
		perform_wall_jump(args[1])
	else:
		player.coyote_timer.start()
		player.animations.play_anim(&"fall")
		
	# Placing this out of the elif block because it can be used simultaneously with
	# the others. Like: coyote time + wall
	if "wall" in args:
		was_on_wall = true
		last_wall_dir = args[1]

func perform_wall_jump(dir: int) -> void:
	is_jumping = true
	player.velocity.x = dir * player.WALL_JUMP_PUSHBACK_FORCE
	player.velocity.y = player.WALL_JUMP_VELOCITY
	
	player.wall_jump_timer.start()
	
	player.animations.play_anim(&"jump", true, true, true)

func perform_jump() -> void:
	is_jumping = true
	player.velocity.y = player.JUMP_VELOCITY
	player.animations.play_anim(&"jump", true, true, true)
	
func process(_delta: float) -> void:
	pass
	
func physics_process(delta: float) -> void:
	var move_input := player.get_move_input()
	var gravity := player.GRAVITY if is_jumping else player.FALL_GRAVITY 
	
	player.set_look_dir(move_input)
	
	if !player.wall_jump_timer.is_stopped() and move_input != last_wall_dir:
		player.velocity.x = move_toward(
			player.velocity.x, 
			move_input * player.SPEED, 
			player.WALL_JUMP_PUSHBACK_ACCELERATION * delta
		)
	else:
		player.velocity.x = move_toward(
			player.velocity.x, 
			move_input * player.SPEED, 
			(player.ACCELERATION * delta) if move_input != 0 else (player.AIR_FRICTION * delta)
		)
	
	player.velocity.y += gravity * delta
	player.velocity.y = min(player.velocity.y, player.MAX_FALL_SPEED)
	
	if is_jumping and player.velocity.y > 0:
		is_jumping = false
	elif !is_jumping:
		player.animations.play_anim(&"fall")
	
	if player.is_on_floor():
		machine.switch(&"ground", ["from_air"])
	elif player.can_wall_jump and player.is_on_wall() and move_input != 0 and player.velocity.y > 0:
		machine.switch(&"wall")
	

func on_action(action: StringName, ..._args: Array) -> void:
	match action:
		&"stop-jump" when is_jumping:
			player.velocity.y *= player.JUMP_CUT_FACTOR
			is_jumping = false
		&"jump":
			if !player.coyote_timer.is_stopped():
				if was_on_wall: perform_wall_jump(last_wall_dir)
				else: perform_jump()
			else:
				player.jump_buffer.start()
		&"attack-pressed":
			machine.switch("attack")

func exit() -> void:
	pass
	
