@icon("uid://chdqlav6o17dg")
class_name RoomBoundsTrigger
extends Area2D

func _on_area_entered(_area: Area2D) -> void:
	GameManager.rooms.set_active_room(owner)
	
