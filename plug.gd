@tool
extends "res://addons/gd-plug/plug.gd"

func _plugging() -> void:
	plug("russmatney/log.gd", { "include": ["addons/log"], "exclude": ["addons/gd-plug", "addons/reload_current_scene", "addons/gdUnit4"] }) 
	
	plug("heygleeson/godot-ldtk-importer")
	pass
