class_name AnimManager
extends AnimationPlayer

@onready var lock_timer := Timer.new()

func _ready() -> void:
	lock_timer.one_shot = true
	add_child(lock_timer)


func play_anim(anim_name: StringName, force := false, restart := false, no_blend := false) -> void:
	if anim_name == current_animation and !restart:
		return
	
	if !lock_timer.is_stopped() and !force: return
	play(anim_name, 0 if no_blend else -1)


func get_anim_duration(anim_name: StringName) -> float:
	return get_animation(anim_name).length


func play_anim_locking(anim_name: StringName, lock_time := -1.0, force := false, restart := false) -> void:
	if anim_name == current_animation and !restart:
		return
	
	if !lock_timer.is_stopped() and !force: return
	
	play(anim_name)
	
	lock_timer.wait_time = lock_time if lock_time > 0 else get_anim_duration(anim_name)
	
	lock_timer.start()
