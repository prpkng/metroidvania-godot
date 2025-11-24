class_name RoomsManager
extends RefCounted

signal on_room_changed(room: LDTKLevel)
var _last_room: LDTKLevel
var _current_room: LDTKLevel

func set_active_room(room: LDTKLevel) -> void:
	_last_room = _current_room
	_current_room = room
	on_room_changed.emit(room)

func get_last_room() -> LDTKLevel:
	return _last_room

func get_active_room() -> LDTKLevel:
	return _current_room
	
