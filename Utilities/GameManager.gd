extends Node
## Base game manager class for the game [br]
## Wires everything together

var wm: WindowManager
var rooms: RoomsManager

func _enter_tree() -> void:
	wm = WindowManager.new()
	rooms = RoomsManager.new()

func _ready() -> void:
	add_child(wm)
