class_name AnimManager
extends AnimatedSprite2D

@onready var lock_timer := Timer.new()

func _ready() -> void:
	lock_timer.one_shot = true
	add_child(lock_timer)


func play_anim(anim_name: StringName, force := false, restart := false) -> void:
	if anim_name == animation and !restart:
		return
	
	if !lock_timer.is_stopped() and !force: return
	
	play(anim_name)

func get_anim_duration(anim_name: StringName) -> float:
	var count := 0.0
	for i in range(sprite_frames.get_frame_count(anim_name)):
		count += sprite_frames.get_frame_duration(anim_name, i)
	
	return count / (sprite_frames.get_animation_speed(anim_name) * abs(get_playing_speed()))
	

func play_anim_locking(anim_name: StringName, lock_time := -1.0, force := false, restart := false) -> void:
	if anim_name == animation and !restart:
		return
	
	if !lock_timer.is_stopped() and !force: return
	
	play(anim_name)
	
	lock_timer.wait_time = lock_time if lock_time > 0 else get_anim_duration(anim_name)
	
	lock_timer.start()
