@icon("res://Entities/World/Camera/Icons/camera_target.svg")
class_name CameraTarget
extends Node2D

signal on_switch_quadrants(new_quadrant: Vector2i)

var _last_quadrant: Vector2i


func _enter_tree() -> void:
	CameraManager.add_target(self)

func _exit_tree() -> void:
	CameraManager.remove_target(self)

func get_current_quadrant() -> Vector2i:
	return (global_position / CameraManager.QUADRANT_SIZE).floor()


func _process(_delta: float) -> void:
	var current := get_current_quadrant()
	
	if current != _last_quadrant:
		on_switch_quadrants.emit(current)
		_last_quadrant = current
