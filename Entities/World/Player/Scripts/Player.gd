class_name Player
extends CharacterBody2D

const SPEED := 130.0
const ACCELERATION := 2600.0
const GROUND_FRICTION := 2400.0
const AIR_FRICTION := 800.0

const GRAVITY := 750.0
const FALL_GRAVITY := 800.0
const WALL_GRAVITY := 25.0
const MAX_FALL_SPEED = 240.0

const JUMP_VELOCITY := -200
const JUMP_CUT_FACTOR := 0.5

const WALL_JUMP_VELOCITY := -200
const WALL_JUMP_PUSHBACK_FORCE := 140
const WALL_JUMP_PUSHBACK_ACCELERATION := 1600
const WALL_JUMP_PUSHBACK_DURATION = 0.2

const JUMP_BUFFER_TIME := 0.1
const COYOTE_TIME := 0.08

@onready var fsm: FSM = $FSM
@onready var sprite: Sprite2D = $Sprite
@onready var animations: AnimManager = $AnimManager
@onready var fsm_label := $Label

@onready var jump_buffer: Timer = CommonUtils.create_and_add_timer(self, JUMP_BUFFER_TIME)
@onready var coyote_timer: Timer = CommonUtils.create_and_add_timer(self, COYOTE_TIME)
@onready var wall_jump_timer: Timer = CommonUtils.create_and_add_timer(self, WALL_JUMP_PUSHBACK_DURATION)


@export_group("Capabilities", "can_")
var can_enabled := false
@export var can_wall_jump := false

var _look_direction: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup FSM states
	fsm.root = StateMachine.new({
		&"ground": PlayerGroundStateMachine.new({
			&"idle": PlayerIdleState.new(),
			&"move": PlayerMoveState.new()
		}),
		&"air": PlayerAirState.new(),
		&"wall": PlayerWallState.new()
	})

	
	# Assign player states to self
	for state: State in fsm.get_all_states(true):
		if state is PlayerState or state is PlayerMachine:
			state.player = self
	
	fsm.start()

## Sets the [member _look_direction] to the given direction if [param dir] != 0
func set_look_dir(dir: int) -> void:
	if dir == 0: return
	_look_direction = dir

## Returns the player horizontal move input
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
	sprite.scale.x = _look_direction
	
