extends Sprite2D


func _ready() -> void:
	set_instance_shader_parameter(&"world_position", global_position)

var tween: Tween

func get_bias() -> float:
	return get_instance_shader_parameter(&"bias")

func set_bias(val: float) -> void:
	set_instance_shader_parameter(&"bias", val)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner is not Player:
		return
	
	var player: Player = area.owner
	
	var dir: float = sign(player.velocity.x)
	
	if dir == 0: return
	
	if tween:
		tween.stop()
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(set_bias, get_bias(), dir, 0.3)
	tween.chain().tween_method(set_bias, dir, dir*.4, 0.5)


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.owner is not Player:
		return
		
	if tween:
		tween.stop()
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(set_bias, get_bias(), 0.0, 0.5)
