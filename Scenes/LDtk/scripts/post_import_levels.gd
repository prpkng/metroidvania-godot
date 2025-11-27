@tool

const SHRINK_SIZE = 16


func post_import(level: LDTKLevel) -> LDTKLevel:
	
	var room_bounds_trigger := load("uid://daqpm0p7h18oo")
	
	var trigger: RoomBoundsTrigger = room_bounds_trigger.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	level.add_child(trigger)
	level.set_editable_instance(trigger, true)
	var shape: CollisionShape2D = trigger.get_node(^"CollisionShape2D")
	var rect := RectangleShape2D.new()
	rect.size = level.size
	rect.size -= Vector2(SHRINK_SIZE / 2.0, SHRINK_SIZE / 2.0)
	shape.position = level.size / 2
	shape.shape = rect
	
	 
	return level
