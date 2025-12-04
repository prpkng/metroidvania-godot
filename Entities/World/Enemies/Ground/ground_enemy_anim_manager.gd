class_name GroundEnemyAnimManager extends AnimManager

const MIN_MOVE_SPD = 10

@export var enemy: AIEnemy

@export var idle_anim_name := &'idle'
@export var move_anim_name := &'move'

var _is_movement_state := false

func _ready() -> void:
	super._ready()
	
	enemy.fsm.state_entered.connect(_on_state_entered)
	

func _on_state_entered(state_name: StringName) -> void:
	match state_name:
		'patrol': 
			_is_movement_state = true

func _process(delta: float) -> void:
	if not _is_movement_state: return
	
	if abs(enemy.velocity.x) > MIN_MOVE_SPD:
		enemy.sprite.flip_h = enemy.velocity.x < 0
		play_anim(move_anim_name)
	else:
		play_anim(idle_anim_name)
