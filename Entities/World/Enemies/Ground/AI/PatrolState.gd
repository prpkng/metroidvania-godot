class_name EnemyPatrolState
extends Node

## A generic patrol behaviour logic that wanders around an area and switches to 
## another state when the player enters the range


@export var detection_range: float = 24

## If true, checks for a clean line of sight between the enemy and the player
@export var check_for_solid := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
