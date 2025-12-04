class_name PhysUtil


static func ray_cast(node: Node2D, from: Vector2, to: Vector2, layer := 0xFFFFFFFF) -> Dictionary:
	var space := node.get_world_2d().direct_space_state
	var parameters := PhysicsRayQueryParameters2D.create(
		from, 
		to, 
		layer
	)
	var result := space.intersect_ray(parameters)
	
	if OS.has_feature('editor') and node.get_tree().debug_navigation_hint:
		DebugDraw.draw_raycast(parameters, result)
	
	return result
