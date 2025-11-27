class_name CommonUtils

static func create_and_add_timer(node: Node, duration: float) -> Timer:
	var timer := Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	node.add_child(timer)
	return timer


static func delay(duration: float) -> void:
	await GameManager.get_tree().create_timer(duration).timeout
