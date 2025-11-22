extends Node
## Base game manager class for the game [br]
## Wires everything together

var wm: WindowManager

func _enter_tree() -> void:
	wm = WindowManager.new()

func _ready() -> void:
	add_child(wm)
