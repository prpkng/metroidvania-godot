class_name PlayerIdleState
extends PlayerState

func enter(_args := []) -> void:
	pass
	
func process(_delta: float) -> void:
	pass
	
func physics_process(delta: float) -> void:
	player.animations.play_anim(&"idle")
	if player.get_move_input() != 0:
		machine.switch(&"move")
	
	player.velocity.x = move_toward(
		player.velocity.x, 
		0, 
		player.GROUND_FRICTION * delta
	)
	
func exit() -> void:
	pass
	
