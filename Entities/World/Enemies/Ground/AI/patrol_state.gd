@tool
class_name EnemyPatrolState
extends EnemyState

## A generic patrol behaviour logic that wanders around an area and switches to 
## another state when the player enters the range


@export var line_of_sight: LineOfSight
@export var destination_state: StringName

@export_group('Movement')
@export var movement_speed := 110.0

@export_group('Patrolling')
@export var wait_time_min := 1.0
@export var wait_time_max := 2.0

@export var patrol_time_min := 2.0
@export var patrol_time_max := 4.0

@export_group('Checks')

@export var check_corners := false
@export var check_walls := true

var is_moving := false
var current_patrol_dir := 1
var current_move_timer: SceneTreeTimer

func enter(_args := []) -> void:
	current_patrol_dir = 1 if randf() > 0.5 else -1
	
	patrol_loop()
	
	line_of_sight.entity_entered_sight.connect(entered_sight)

func wait_movement() -> void:
	var wait_time := randf_range(patrol_time_min, patrol_time_max)
	current_move_timer = get_tree().create_timer(wait_time)
	await current_move_timer.timeout
	
	current_move_timer = null
	if machine._current_state != self: return

func wait_cooldown() -> void:
	var wait_time := randf_range(wait_time_min, wait_time_max)
	await get_tree().create_timer(wait_time).timeout
	if machine._current_state != self: return

func pick_new_direction() -> int:
	if enemy.is_on_wall():
		var wall_normal_x: int = sign(enemy.get_wall_normal().x)
		if wall_normal_x == 0: Log.error("Somehow the enemy ran into a wall with normalX = 0???")
		return wall_normal_x
	
	if randf() > 0.45:
		return -current_patrol_dir
	
	return current_patrol_dir

func patrol_loop() -> void:
	is_moving = true
	await wait_movement()
	
	is_moving = false
	await wait_cooldown()
	
	current_patrol_dir = pick_new_direction()
	
	patrol_loop()

func entered_sight(_node: Node2D) -> void:
	machine.switch(destination_state)

func process(_delta: float) -> void:
	pass
	
func physics_process(_delta: float) -> void:
	if is_moving:
		enemy.velocity.x = movement_speed * current_patrol_dir
	else:
		enemy.velocity.x = 0
	
	if current_move_timer != null and enemy.is_on_wall():
		var wall_dir: int = sign(enemy.get_wall_normal().x)
		if -wall_dir == current_patrol_dir:
			current_move_timer.timeout.emit()

	
func exit() -> void:
	line_of_sight.entity_entered_sight.disconnect(entered_sight)
	
