class_name AIEnemy extends BaseEnemy

@export var fsm: StateMachine

func _ready() -> void:
	if fsm == null: return
	
	for state: State in fsm.get_all_states(true):
		if state is EnemyState:
			state.enemy = self
	
	fsm.init()
	
