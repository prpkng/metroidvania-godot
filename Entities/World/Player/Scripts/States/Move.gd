class_name PlayerMoveState
extends PlayerState

func _enter(_args := []) -> void:
	pass
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	var move_input := player.get_move_input()
	if move_input == 0:
		machine.switch(&"idle")
	
	player.animations.play_anim(&"move")
	player.set_look_dir(move_input)
	
	
	player.velocity.x = move_toward(
		player.velocity.x, 
		move_input * player.SPEED, 
		player.ACCELERATION * delta
	)
	
func _exit() -> void:
	pass
	
