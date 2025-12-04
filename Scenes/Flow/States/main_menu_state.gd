
class_name MainMenuState
extends GameStateBase

var menu_scene: Control

func get_state_name() -> String:
	return "MainMenu"

func get_state_type() -> StateType:
	return StateType.EXCLUSIVE

func enter(previous_state: GameStateBase) -> void:
	super.enter(previous_state)
	
	menu_scene = load("res://Scenes/UI/main_menu.tscn").instantiate()
	add_child(menu_scene)
	connect_menu_signals()

func cleanup() -> void:
	if menu_scene:
		menu_scene.queue_free()
		menu_scene = null

func connect_menu_signals() -> void:
	if !menu_scene:
		return
	
	var start_button = menu_scene.find_child("StartButton") as Button
	
	if start_button:
		start_button.pressed.connect(func(): state_manager.change_state("Gameplay"))
