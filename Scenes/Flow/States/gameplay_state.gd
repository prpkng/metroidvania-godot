class_name GameplayState
extends GameStateBase

const PLAYER_PATH := "res://Entities/World/Player/player.tscn" # Player
const WORLD_PATH := "res://Scenes/Worlds/underground.tscn" # World
const CAMERA_PATH := "res://Entities/World/Camera/ingame_camera.tscn" # Camera

const LEVEL0_IID = "2322e280-ac70-11f0-a9d5-cfdfe144059f"


var player: Player
var camera_manager: CameraManager
var world: WorldManager

func get_state_name() -> String:
	return "Gameplay"

func get_state_type() -> StateType:
	return StateType.EXCLUSIVE

func enter(previous_state: GameStateBase) -> void:
	super.enter(previous_state)
	
	Log.debug("Loading gameplay...")
	
	get_tree().paused = true
	
	await create_nodes()
	
	await prepare_game()
	
	await begin_game()
	
	get_tree().paused = false
	
	
	_enable_gameplay()
	Log.debug("Gameplay started!")


func create_nodes() -> void:
	player = load(PLAYER_PATH).instantiate()
	camera_manager = load(CAMERA_PATH).instantiate()
	world = load(WORLD_PATH).instantiate()
	
	add_child(player)
	add_child(camera_manager)
	add_child(world)
	
	await CommonUtils.delay(0.1)
	

func prepare_game() -> void:
	player.global_position = world.get_player_start_at(LEVEL0_IID)
	
	camera_manager.add_target(player)
	camera_manager.set_current_target(0)
	
	await CommonUtils.delay(0.1)

func begin_game() -> void:
	await CommonUtils.delay(0.1)


func hide_state() -> void:
	super.hide_state()
	_disable_gameplay()

func show_state() -> void:
	super.show_state()
	_enable_gameplay()

func cleanup() -> void:
	# Only cleanup when truly exiting (going to main menu)
	player.queue_free()
	camera_manager.queue_free()
	world.queue_free()

func _enable_gameplay() -> void:
	player.set_process_mode(Node.PROCESS_MODE_INHERIT)
	world.set_process_mode(Node.PROCESS_MODE_INHERIT)

func _disable_gameplay() -> void:
	player.set_process_mode(Node.PROCESS_MODE_DISABLED)
	world.set_process_mode(Node.PROCESS_MODE_DISABLED)

func update(delta: float) -> void:
	# Check for pause input
	if Input.is_action_just_pressed("ui_cancel"):
		state_manager.push_state("Paused")
