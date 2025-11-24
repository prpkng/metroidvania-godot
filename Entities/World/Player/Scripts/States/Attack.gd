class_name PlayerAttackState
extends PlayerState

const HIT_PARTICLES = preload("uid://isbjw8snrqpn")

func enter(_args := []) -> void:
	player.attack_cooldown_timer.start()
	
	var boost := player.ATTACK_YBOOST
	if player.velocity.y < 15:
		boost *= 1
	
	player.velocity.y = boost
	player.velocity.x = player._look_direction * player.ATTACK_XBOOST
	
	player.weapon.visible = false
	
	await player.animations.play_anim_async(&"sword_slash", true, true, true)
	if machine._current_state != self or !machine or !player: return
	
	if player.is_on_floor():
		machine.switch("ground")
	else:
		machine.switch("air")


func process(_delta: float) -> void:
	pass
	
func physics_process(delta: float) -> void:
	var move_input := player.get_move_input()
	
	player.velocity.x = move_toward(
		player.velocity.x, 
		move_input * player.SPEED, 
		player.ATTACK_FRICTION * delta
	)
	
	player.velocity.y += player.GRAVITY * delta
	player.velocity.y = min(player.velocity.y, player.MAX_FALL_SPEED)

func on_action(action: StringName, ..._args: Array) -> void:
	match action:
		&"hit-solid":
			var space := player.get_world_2d().direct_space_state
			var query := PhysicsRayQueryParameters2D.create(
				player.global_position + Vector2.UP*4,
				player.global_position + Vector2(player._look_direction * player.weapon.main_shape.shape.get_rect().size.x, 0),
				player.weapon.hitbox.collision_mask
			)
			var result := space.intersect_ray(query)
			if result.is_empty(): return
			
			var normal: Vector2 = result["normal"]
			var dir: int = sign(normal.x)
			player.velocity.x = player.ATTACK_WALL_BUMP.x * dir
			player.velocity.y = player.ATTACK_WALL_BUMP.y
			machine.switch("air")
			
			var particles: GPUParticles2D = HIT_PARTICLES.instantiate()
			player.owner.add_child(particles)
			particles.global_position = result["position"] - normal*4
			particles.transform.x = normal
			particles.emitting = true
			particles.finished.connect(particles.queue_free)
			#particles.emitting = true
	
func exit() -> void:
	player.weapon.visible = true
	player.weapon.deactivate()
	
