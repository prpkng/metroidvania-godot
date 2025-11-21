class_name CameraManager
extends Camera2D

const QUADRANT_SIZE := Vector2(256, 240)
const GOING_UP_SMOOTHING := 12

# == STATIC ==

static var _available_targets: Array[CameraTarget]

static func add_target(target: CameraTarget) -> void:
	Log.info("Adding new target to camera: ", target)
	_available_targets.push_back(target)

static func remove_target(target: CameraTarget) -> void:
	_available_targets.erase(target)
	Log.info("Removing target from camera: ", target)

# ============

var current_target: CameraTarget
var current_quadrant: Vector2i

var _going_up_timer: Timer


func _ready() -> void:
	set_current_target(0)


func set_current_target(index: int) -> void:
	if index < 0 or index >= _available_targets.size():
		Log.error("Index [%s] out of range of available targets!" % index)
		return
	
	Log.info("Set camera current target to: ", _available_targets[index])
		
	if current_target:
		current_target.on_switch_quadrants.disconnect(_on_target_switch_quadrants)
	current_target = _available_targets[index]
	current_target.on_switch_quadrants.connect(_on_target_switch_quadrants)
	
	set_pos_to_quadrant(current_target.get_current_quadrant())
	


func set_pos_to_quadrant(quadrant: Vector2i) -> void:
	if _going_up_timer and !_going_up_timer.is_stopped():
		_going_up_timer.timeout.emit()
		_going_up_timer.stop()
	
	if quadrant.y < current_quadrant.y:
		_going_up_timer = CommonUtils.create_and_add_timer(self, 0.25)
		#var last_smoothing := position_smoothing_speed
		#position_smoothing_speed = GOING_UP_SMOOTHING
		position_smoothing_enabled = false
		
		_going_up_timer.timeout.connect(func() -> void: 
			#position_smoothing_speed = last_smoothing
			position_smoothing_enabled = true
			_going_up_timer.queue_free()
		)
		_going_up_timer.start()
		# Going up
		
	
	position = quadrant as Vector2 * QUADRANT_SIZE + QUADRANT_SIZE/2
	current_quadrant = quadrant

func _on_target_switch_quadrants(new_quadrant: Vector2i) -> void:
	set_pos_to_quadrant(new_quadrant)
