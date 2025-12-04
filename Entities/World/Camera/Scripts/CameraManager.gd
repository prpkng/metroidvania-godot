class_name CameraManager
extends Camera2D

const QUADRANT_SIZE := Vector2(256, 240)
const GOING_UP_SMOOTHING := 12

var _available_targets: Array[Node2D]

func add_target(target: Node2D) -> void:
	Log.debug("Adding new target to camera: ", target)
	_available_targets.push_back(target)

func remove_target(target: Node2D) -> void:
	_available_targets.erase(target)
	Log.debug("Removing target from camera: ", target)

var current_target: Node2D

func _ready() -> void:
	GameManager.rooms.on_room_changed.connect(_on_room_changed)


func set_current_target(index: int, teleport := true) -> void:
	if index < 0 or index >= _available_targets.size():
		Log.error("Index [%s] out of range of available targets!" % index)
		return
	
	Log.debug("Set camera current target to: ", _available_targets[index])
		
	current_target = _available_targets[index]
	
	if teleport: position_smoothing_enabled = false
	
	global_position = current_target.global_position
	
	if teleport:
		await get_tree().process_frame
		position_smoothing_enabled = true
	

func _on_room_changed(room: LDTKLevel) -> void:
	var limit_pos := room.world_position
	var limit_size := room.size
	limit_left = limit_pos.x as int
	limit_right = limit_pos.x+limit_size.x as int
	limit_top = limit_pos.y as int
	limit_bottom = limit_pos.y+limit_size.y as int
	
	var last_room := GameManager.rooms.get_last_room()
	if last_room and room.position.y < last_room.position.y:
		reset_smoothing.call_deferred()

func _process(_delta: float) -> void:
	if current_target == null: return
	global_position = current_target.global_position
