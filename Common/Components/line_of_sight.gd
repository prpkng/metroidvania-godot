@tool
class_name LineOfSight extends Area2D

@export var detection_range: float = 32:
	set(value):
		detection_range = value
		if not Engine.is_editor_hint(): return
		circle_shape.radius = value
		queue_redraw()
@export var check_areas := true
@export var check_bodies := true


@export_flags_2d_physics var obfuscation_layer := 0b00000000_00000000_00000000_00000010

var circle_shape: CircleShape2D
var collision_shape: CollisionShape2D
var visible_notifier: VisibleOnScreenNotifier2D

var overlapping_entities: Array[Node2D] = []

var _entities_in_sight: Array[Node2D] = []

signal entity_entered_sight(node: Node2D)
signal entity_exited_sight(node: Node2D)


#region debug_draw

func _draw() -> void:
	if not Engine.is_editor_hint() and !get_tree().debug_navigation_hint: return
	
	var color := (Color.LAWN_GREEN - Color.BLACK*.9 if overlapping_entities.is_empty() 
				else Color.LAWN_GREEN)
	draw_circle(position, detection_range, color, false, 0.9)


#endregion


func _ready() -> void:

	if check_bodies:
		body_entered.connect(_on_entered)
		body_exited.connect(_on_exited)
	if check_areas:
		area_entered.connect(_on_entered)
		area_exited.connect(_on_exited)
	
	
	if not Engine.is_editor_hint() or get_children().size() > 0: return
	
	collision_shape = CollisionShape2D.new()
	circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_range
	
	collision_shape.visible = false
	collision_shape.shape = circle_shape
	collision_shape.name = "CollisionShape"
	collision_shape.debug_color = Color.TRANSPARENT
	
	add_child(collision_shape, false, INTERNAL_MODE_BACK)
	collision_shape.owner = get_tree().edited_scene_root
	


func _on_entered(body: Node2D) -> void:
	if get_tree().debug_navigation_hint:
		queue_redraw()
	overlapping_entities.append(body) 


func _on_exited(body: Node2D) -> void:
	if get_tree().debug_navigation_hint:
		queue_redraw()
	overlapping_entities.erase(body) 
	
	

func _is_line_clear(from: Vector2, to: Vector2) -> bool:
	return PhysUtil.ray_cast(self, from, to, obfuscation_layer).is_empty()


func get_entities_in_sight() -> Array[Node2D]:
	return overlapping_entities.filter(
		func(entity: Node2D) -> bool:
			return _is_line_clear(global_position, entity.global_position)
	)


func is_in_sight(node: Node2D) -> bool:
	if node not in overlapping_entities:
		return false
	return _is_line_clear(global_position, node.global_position)



func _process(_delta: float) -> void:
	if !entity_entered_sight.has_connections() and !entity_exited_sight.has_connections(): 
		return
	
	for entity: Node2D in overlapping_entities:
		var is_clear := _is_line_clear(global_position, entity.global_position)
		
		if is_clear and entity not in _entities_in_sight:
			_entities_in_sight.append(entity)
			entity_entered_sight.emit(entity)
		elif !is_clear and entity in _entities_in_sight:
			_entities_in_sight.erase(entity)
			entity_exited_sight.emit(entity)
			
	
	
