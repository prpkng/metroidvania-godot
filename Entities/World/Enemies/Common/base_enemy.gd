class_name BaseEnemy
extends CharacterBody2D

## The base class of all enemies, with common functionality

@onready var health: Health = $Health
@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(_delta: float) -> void:
	move_and_slide()
