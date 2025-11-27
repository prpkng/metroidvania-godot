class_name WorldManager
extends Node2D

@onready var ldtk_world: LDTKWorld = $"metroidvania-maps"

func get_level(level_iid: String) -> LDTKLevel:
	for lvl: LDTKLevel in ldtk_world.levels:
		if lvl.iid == level_iid:
			return lvl
	
	Log.error("Failed to find a level with the given IID: %s" % level_iid)
	return null

func get_level_info(level_iid: String) -> LDtkLevelInfo:
	var lvl := get_level(level_iid)
	assert(lvl != null)
	return lvl.get_node("LevelInfo")


func get_player_start_at(level_iid: String) -> Vector2:
	var info := get_level_info(level_iid)
	assert(info != null)
	return info.player_start.global_position
	
