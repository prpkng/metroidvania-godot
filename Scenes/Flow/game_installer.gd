extends Node2D

var state_manager: GameStateManager

func _ready() -> void:
	initialize()


func initialize() -> void:
	await initialize_services()
	
	Log.info("Starting game initialization! ")
	state_manager = GameStateManager.new()
	add_child(state_manager)
	
	state_manager.register_state(GameplayState.new())
	state_manager.register_state(MainMenuState.new())
	
	#state_manager.change_state("MainMenu")
	state_manager.change_state("Gameplay")


func initialize_services() -> void:
	Log.set_log_level(Log.Levels.DEBUG)
	
	await CommonUtils.delay(0.1)

func begin_game() -> void:
	await CommonUtils.delay(0.1)
