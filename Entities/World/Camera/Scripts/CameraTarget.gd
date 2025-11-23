@icon("res://Entities/World/Camera/Icons/camera_target.svg")
class_name CameraTarget
extends Node2D

func _enter_tree() -> void:
	CameraManager.add_target(self)

func _exit_tree() -> void:
	CameraManager.remove_target(self)
