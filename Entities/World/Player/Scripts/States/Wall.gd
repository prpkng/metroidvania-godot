class_name PlayerWallState
extends PlayerState

var wall_side: int

func enter(_args := []) -> void:
	if !player.is_on_wall():
		# Log because this should not be happening here
		Log.err("Somehow the player entered on Wall state without being on a wall!")
		return
		
	wall_side = sign(player.get_wall_normal().x)
	player.set_look_dir(wall_side)
	
	
func process(_delta: float) -> void:
	pass
	
func physics_process(_delta: float) -> void:
	var move_input := player.get_move_input()
	player.animations.play_anim(&"idle")
	
	player.velocity.x = 0
	player.velocity.y = player.WALL_GRAVITY
	
	
	if !player.is_on_wall() or move_input == 0:
		machine.switch(&"air", ["wall", wall_side])
	elif move_input != -sign(player.get_wall_normal().x):
		machine.switch(&"air", ["wall", wall_side])
	elif player.is_on_floor():
		machine.switch(&"ground")
	
	
	if !player.jump_buffer.is_stopped():
		on_action(&"jump")

func on_action(action: StringName, ...args: Array) -> void:
	super.on_action(action, args)
	if action == &"jump":
		machine.switch("air", ["wall_jump", wall_side])

func exit() -> void:
	pass
	
