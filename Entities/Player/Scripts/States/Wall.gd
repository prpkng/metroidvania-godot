class_name PlayerWallState
extends PlayerState

var wall_side: int

func _enter(_args := []) -> void:
	if !player.is_on_wall():
		# Log because this should not be happening here
		Log.err("Somehow the player entered on Wall state without being on a wall!")
		return
		
	wall_side = sign(player.get_wall_normal().x)
	player.set_look_dir(wall_side)
	
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	var move_input := player.get_move_input()
	player.sprite.play_anim(&"idle")
	
	player.velocity.x = 0
	player.velocity.y = player.WALL_GRAVITY
	
	
	if !player.is_on_wall() or move_input == 0:
		machine.switch(&"air", ["wall", wall_side])
	elif move_input != -sign(player.get_wall_normal().x):
		machine.switch(&"air", ["wall", wall_side])
	elif player.is_on_floor():
		machine.switch(&"ground")
	
	
	if !player.jump_buffer.is_stopped():
		_on_action(&"jump")

func _on_action(action: StringName, ...args: Array) -> void:
	super._on_action(action, args)
	if action == &"jump":
		machine.switch("air", ["wall_jump", wall_side])

func _exit() -> void:
	pass
	
