class_name PlayerAttackState
extends PlayerState

func _enter(_args := []) -> void:
	player.attack_cooldown_timer.start()
	
	if player.velocity.y > 10:
		player.velocity.y = player.ATTACK_YBOOST
	player.velocity.x = player._look_direction * player.ATTACK_XBOOST
	
	player.weapon.visible = false
	
	await player.animations.play_anim_async(&"sword_slash", true, true, true)
	if machine._current_state_name != name or !machine or !player: return
	
	if player.is_on_floor():
		machine.switch("ground")
	else:
		machine.switch("air")


func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	var move_input := player.get_move_input()
	
	player.velocity.x = move_toward(
		player.velocity.x, 
		move_input * player.SPEED, 
		player.ATTACK_FRICTION * delta
	)
	
	player.velocity.y += player.FALL_GRAVITY * delta
	player.velocity.y = min(player.velocity.y, player.MAX_FALL_SPEED)

func _on_action(action: StringName, ..._args: Array) -> void:
	match action:
		&"hit-solid":
			Log.info("Hit a wall!")
			var space := player.get_world_2d().direct_space_state
			var query := PhysicsRayQueryParameters2D.create(
				player.global_position,
				Vector2(player._look_direction * player.weapon.main_shape.shape.get_rect().size.x, 0),
				player.weapon.hitbox.collision_mask
			)
			var result := space.intersect_ray(query)
			if result.is_empty(): return
			
			var normal: Vector2 = result["normal"]
			var dir: int = sign(normal.x)
			player.velocity.x = player.ATTACK_WALL_BUMP.x * dir
			player.velocity.y = player.ATTACK_WALL_BUMP.y
			machine.switch("air")
			
			
	
func _exit() -> void:
	player.weapon.visible = true
	player.weapon.deactivate()
	
