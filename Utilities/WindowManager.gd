class_name WindowManager
extends RefCounted

const MAIN_WIDTH := 320.0
const MAIN_HEIGHT := 180.0

const DEFAULT_MULTIPLE := 5

func get_display_size() -> Vector2i:
	return DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)

func set_window_size(size: Vector2i, autocenter := true) -> void:
	DisplayServer.window_set_size(size)
	if autocenter:
		center_window()

func center_window() -> void:
	var size := DisplayServer.window_get_size()
	var pos := get_display_size() / 2.0 - size / 2.0
	DisplayServer.window_set_position(pos)

func _init() -> void:
	var display_size := get_display_size()
	var multiple := DEFAULT_MULTIPLE
	
	while (display_size.x / MAIN_WIDTH < multiple or 
		display_size.y / MAIN_HEIGHT < multiple) and multiple > 1:
		multiple -= 1
	
	var size := Vector2(MAIN_WIDTH * multiple, MAIN_HEIGHT * multiple).round()
	set_window_size(size)
	Log.info("Setting up window of ", size)
	
