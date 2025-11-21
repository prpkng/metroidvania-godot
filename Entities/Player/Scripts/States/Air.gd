class_name PlayerAirState
extends PlayerState

var was_on_wall := false
var last_wall_dir := 0

var is_jumping := false

func _enter(args := []) -> void:
	player.jump_buffer.stop()
	is_jumping = false
	was_on_wall = false
	last_wall_dir = 0
	
	if "jump" in args:
		perform_jump()
	elif "wall_jump" in args:
		perform_wall_jump(args[1])
	else:
		player.coyote_timer_available = true
		player.coyote_timer.start()
		player.sprite.play_anim(&"air")
		
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
	
	player.sprite.play_anim(&"jump")

func perform_jump() -> void:
	is_jumping = true
	player.velocity.y = player.JUMP_VELOCITY
	player.sprite.play_anim(&"jump")
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
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
	
	if player.is_on_floor():
		machine.switch(&"ground", ["from_air"])
	elif player.is_on_wall() and move_input != 0 and player.velocity.y > 0:
		machine.switch(&"wall")
	

func _on_action(action: StringName, ..._args: Array) -> void:
	if action == &"stop-jump" and is_jumping:
		player.velocity.y *= player.JUMP_CUT_FACTOR
		is_jumping = false
	elif action == &"jump":
		if !player.coyote_timer.is_stopped():
			if was_on_wall: perform_wall_jump(last_wall_dir)
			else: perform_jump()
		else:
			player.jump_buffer.start()

func _exit() -> void:
	pass
	
