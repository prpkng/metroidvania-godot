class_name Player
extends CharacterBody2D

const SPEED := 130.0
const ACCELERATION := 2600.0
const GROUND_FRICTION := 2400.0
const AIR_FRICTION := 800.0

const GRAVITY := 750.0
const FALL_GRAVITY := 800.0
const WALL_GRAVITY := 25.0
const MAX_FALL_SPEED = 400.0

const JUMP_VELOCITY := -200
const JUMP_CUT_FACTOR := 0.5
const WALL_JUMP_VELOCITY := 100
const WALL_JUMP_PUSHBACK := 80

const JUMP_BUFFER_TIME := 0.1
const COYOTE_TIME := 0.08

@onready var fsm: FSM = $FSM
@onready var sprite: AnimManager = $Sprite
@onready var fsm_label := $Label

var jump_buffer: Timer
var coyote_timer: Timer
var coyote_timer_available := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Setup jump timers
	
	jump_buffer = Timer.new()
	jump_buffer.wait_time = JUMP_BUFFER_TIME
	jump_buffer.one_shot = true
	add_child(jump_buffer)
	
	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	coyote_timer.timeout.connect(_on_coyote_timeout)
	add_child(coyote_timer)
	
	# Setup FSM states
	fsm.root = StateMachine.new({
		&"ground": PlayerGroundStateMachine.new({
			&"idle": PlayerIdleState.new(),
			&"move": PlayerMoveState.new()
		}),
		&"air": PlayerAirState.new()
	})

	
	# Assign player states to self
	for state: State in fsm.get_all_states(true):
		if state is PlayerState or state is PlayerMachine:
			state.player = self
	
	fsm.start()

func get_move_input() -> int:
	var input := Input.get_axis(&"move_left", &"move_right")
	return sign(input) if abs(input) > 0.1 else 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"jump"):
		fsm.root.trigger(&"jump")
	elif event.is_action_released(&"jump"):
		fsm.root.trigger(&"stop-jump")

func _physics_process(_delta: float) -> void:
	move_and_slide()
	fsm_label.text = fsm.root.get_leaf_state().get_full_hierarchy()
	var move_input := get_move_input()
	if move_input != 0: sprite.flip_h = move_input < 0
	
func _on_coyote_timeout() -> void:
	coyote_timer_available = false
