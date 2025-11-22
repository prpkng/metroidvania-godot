@icon("uid://dop2cp7l4ve08")
class_name Weapon
extends Node2D

@export var active: bool
@onready var hitbox: HitBox2D = $HitBox2D
@onready var main_shape: CollisionShape2D = $HitBox2D/CollisionShape2D

signal hit_environment(area: Area2D)
signal hit_solid(body: PhysicsBody2D)
signal hit_hitbox(hitbox: HitBox2D)
signal hit_hurtbox(hurtbox: HurtBox2D)

func _ready() -> void:
	if active: activate()
	else: deactivate()


func activate() -> void:
	if active: return
	active = true
	main_shape.set_deferred(&"disabled", false)
	main_shape.disabled = false
	

func deactivate() -> void:
	if !active: return
	hitbox.ignore_collisions = true
	main_shape.set_deferred(&"disabled", true)
	active = false


func _on_hitbox_entered(hit_box: HitBox2D) -> void:
	hit_hitbox.emit(hit_box)


func _on_hurtbox_entered(hurt_box: HurtBox2D) -> void:
	hit_hurtbox.emit(hurt_box)


func _on_unknown_area_entered(area: Area2D) -> void:
	hit_environment.emit(area)

func _on_body_entered(body: Node2D) -> void:
	hit_solid.emit(body as PhysicsBody2D)
