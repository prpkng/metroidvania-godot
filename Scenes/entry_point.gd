extends Node2D

var player: Player
var world: WorldManager
var camera_manager: CameraManager


const PLAYER_PATH := "res://Entities/World/Player/player.tscn" # Player
const WORLD_PATH := "res://Scenes/Worlds/underground.tscn" # World
const CAMERA_PATH := "res://Entities/World/Camera/ingame_camera.tscn" # Camera

const LEVEL0_IID = "2322e280-ac70-11f0-a9d5-cfdfe144059f"

func _ready() -> void:
	initialize()


func initialize() -> void:
	Log.info("Starting game initialization! ")
	
	get_tree().paused = true
	
	await initialize_services()
	
	await load_scenes()
	
	await create_nodes()
	
	await prepare_game()

	await begin_game()
	
	get_tree().paused = false



func initialize_services() -> void:
	await CommonUtils.delay(0.1)

func load_scenes() -> void:
	var loading_assets := [PLAYER_PATH, WORLD_PATH, CAMERA_PATH]
	
	for asset_path: String in loading_assets:
		ResourceLoader.load_threaded_request(asset_path)
	
	var timer := Timer.new()
	add_child(timer)
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.wait_time = 0.025
	timer.start()
	
	var finished := false
	while !finished:
		finished = true
		for asset_path: String in loading_assets:
			match ResourceLoader.load_threaded_get_status(asset_path):
				ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
					Log.error("Failed loading asset: %s" % asset_path)
					get_tree().quit()
				ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					finished = false
					break
		await timer.timeout


func create_nodes() -> void:
	
	player = ResourceLoader.load_threaded_get(PLAYER_PATH).instantiate()
	camera_manager = ResourceLoader.load_threaded_get(CAMERA_PATH).instantiate()
	world = ResourceLoader.load_threaded_get(WORLD_PATH).instantiate()
	
	add_child(player)
	add_child(camera_manager)
	add_child(world)
	

func prepare_game() -> void:
	player.global_position = world.get_player_start_at(LEVEL0_IID)
	
	camera_manager.add_target(player)
	camera_manager.set_current_target(0)
	
	await CommonUtils.delay(0.1)

func begin_game() -> void:
	await CommonUtils.delay(0.1)
