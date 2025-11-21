class_name PlayerIdleState
extends PlayerState

func _enter(_args := []) -> void:
	pass
	
func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	player.sprite.play_anim(&"idle")
	if player.get_move_input() != 0:
		machine.switch(&"move")
	
	player.velocity.x = move_toward(
		player.velocity.x, 
		0, 
		player.GROUND_FRICTION * delta
	)
	
func _exit() -> void:
	pass
	
