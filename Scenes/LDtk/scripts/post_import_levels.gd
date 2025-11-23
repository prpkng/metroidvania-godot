@tool

const ROOM_BOUNDS_TRIGGER = preload("uid://daqpm0p7h18oo")

func post_import(level: LDTKLevel) -> LDTKLevel:
	
	var trigger: RoomBoundsTrigger = ROOM_BOUNDS_TRIGGER.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	level.add_child(trigger)
	level.set_editable_instance(trigger, true)
	var shape: CollisionShape2D = trigger.get_node(^"CollisionShape2D")
	var rect := RectangleShape2D.new()
	rect.size = level.size
	shape.position = level.size / 2
	shape.shape = rect
	 
	return level
