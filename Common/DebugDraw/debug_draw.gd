# Autoload script
extends Node

# ==== A simple debug draw helper class ====
# Note that this system is meant to be handy, not performant
# Therefore, don't use it in production!!!

class DrawCall:
	var color: Color
	var lifetime: float = -1
	var antialiased: bool
	var width: float

class LineDrawCall extends DrawCall:
	var from: Vector2
	var to: Vector2
	
class RectDrawCall extends DrawCall:
	var rect: Rect2
	
class CircleDrawCall extends DrawCall:
	var origin: Vector2
	var radius: float
	
class ArrowDrawCall extends DrawCall:
	var from: Vector2
	var to: Vector2
	var head_length: float
	var head_angle: float
	
class PolygonDrawCall extends DrawCall:
	var points: PackedVector2Array
	

var drawing_node: Node2D
var _batched_calls: Array[DrawCall] = []

func remove_draw_call(draw_call: DrawCall) -> void:
	_batched_calls.erase(draw_call)
	drawing_node.queue_redraw()

func add_draw_call(draw_call: DrawCall) -> void:
	if draw_call.lifetime == -1 and Engine.is_in_physics_frame():
		draw_call.lifetime = get_physics_process_delta_time()
	_batched_calls.push_back(draw_call)
	drawing_node.queue_redraw()


func _ready() -> void:
	drawing_node = Node2D.new()
	drawing_node.z_as_relative = false
	drawing_node.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	add_child.call_deferred(drawing_node)
	
	drawing_node.draw.connect(_draw)

# === DRAW COMMANDS ======

func draw_line(
	from: Vector2, 
	to: Vector2, 
	color: Color,
	width: float = 1, 
	duration: float = -1,
	antialiased: bool = false) -> void:
	
	var draw_call := LineDrawCall.new()
	draw_call.from = from
	draw_call.to = to
	draw_call.color = color
	draw_call.width = width
	draw_call.lifetime = duration
	draw_call.antialiased = antialiased
	
	add_draw_call(draw_call)


func draw_circle(
	origin: Vector2, 
	radius: float, 
	color: Color,
	width: float = -1, 
	duration: float = -1,
	antialiased: bool = false) -> void:
	
	var draw_call := CircleDrawCall.new()
	draw_call.origin = origin
	draw_call.radius = radius
	draw_call.color = color
	draw_call.width = width
	draw_call.lifetime = duration
	draw_call.antialiased = antialiased
	
	add_draw_call(draw_call)

func draw_rect(
	rect: Rect2, 
	color: Color,
	width: float = -1, 
	duration: float = -1,
	antialiased: bool = false) -> void:
	
	var draw_call := RectDrawCall.new()
	draw_call.rect = rect
	draw_call.color = color
	draw_call.width = width
	draw_call.lifetime = duration
	draw_call.antialiased = antialiased
	
	add_draw_call(draw_call)

func draw_poly(
	points: PackedVector2Array, 
	color: Color,
	width: float = -1, 
	duration: float = -1,
	antialiased: bool = false) -> void:
	
	var draw_call := PolygonDrawCall.new()
	draw_call.points = points
	draw_call.color = color
	draw_call.width = width
	draw_call.lifetime = duration
	draw_call.antialiased = antialiased
	
	add_draw_call(draw_call)

func draw_arrow(
	from: Vector2, 
	to: Vector2, 
	color: Color,
	width: float = 1, 
	duration: float = -1,
	antialiased: bool = false,
	head_length: float = 6, 
	head_angle: float = 25
) -> void:
	assert(0 < head_angle and head_angle < 90, "Head angle MUST be between 0-90deg!")
	
	var draw_call := ArrowDrawCall.new()
	draw_call.from = from
	draw_call.to = to
	draw_call.color = color
	draw_call.width = width
	draw_call.lifetime = duration
	draw_call.antialiased = antialiased
	draw_call.head_length = head_length
	draw_call.head_angle = head_angle
	
	add_draw_call(draw_call)

# === OTHER HELPERS ===

const RAYCAST_NORMAL_LENGTH = 20
const RAYCAST_CLEAR_COLOR = Color.LAWN_GREEN
const RAYCAST_HIT_LINE_COLOR = Color.INDIAN_RED
const RAYCAST_HIT_OBSTACLE_COLOR = Color.LIME_GREEN - Color.BLACK*.15
const RAYCAST_HIT_NORMAL_COLOR = Color.MEDIUM_PURPLE - Color.BLACK*.5
const RAYCAST_HIT_RECT_COLOR = Color.WHITE - Color.BLACK*.15
const RAYCAST_HIT_RECT_SIZE = Vector2.ONE * 6

func draw_raycast(query: PhysicsRayQueryParameters2D, results: Dictionary) -> void:
	if results.is_empty(): # Hit passed
		draw_arrow(query.from, query.to, RAYCAST_CLEAR_COLOR)
		return
	
	var point: Vector2 = results['position']
	#draw_rect(
		#Rect2(point-RAYCAST_HIT_RECT_SIZE/2, RAYCAST_HIT_RECT_SIZE), 
		#RAYCAST_HIT_RECT_COLOR, 
		#1
	#)
	draw_circle(
		point,
		3,
		RAYCAST_HIT_RECT_COLOR, 
		1
	)
	
	draw_arrow(query.from, point, RAYCAST_HIT_OBSTACLE_COLOR)
	
	var normal_vec: Vector2 = results['normal'] * 20
	draw_line(point, point + normal_vec, RAYCAST_HIT_NORMAL_COLOR)
	
	draw_line(point, query.to, RAYCAST_HIT_LINE_COLOR)

# ========================

func _process(delta: float) -> void:
	for draw_call: DrawCall in _batched_calls:
		draw_call.lifetime -= delta
		if draw_call.lifetime < 0: 
			remove_draw_call.call_deferred(draw_call)
	


# ======= LOGIC =======

func _draw_line(draw_call: LineDrawCall) -> void:
	drawing_node.draw_line(
		draw_call.from,
		draw_call.to, 
		draw_call.color, 
		draw_call.width, 
		draw_call.antialiased
	)

func _draw_polygon(draw_call: PolygonDrawCall) -> void:
	if draw_call.width == -1:
		drawing_node.draw_colored_polygon(
			draw_call.points, 
			draw_call.color
		)
	else: 
		drawing_node.draw_polyline(
			draw_call.points, 
			draw_call.color,
			draw_call.width,
			draw_call.antialiased
		)
		
func _draw_arrow(draw_call: ArrowDrawCall) -> void:
	var is_filled := draw_call.width < 0
	var head_dir := (draw_call.to - draw_call.from).normalized()
	
	var head_width := draw_call.head_length * tan(deg_to_rad(draw_call.head_angle))
	
	var head_start := draw_call.to - head_dir * draw_call.head_length
	var dest := draw_call.to if is_filled else head_start
	
	
	var head_points := PackedVector2Array([
						draw_call.to,
						head_start + head_dir.rotated(PI/2) * head_width,
						head_start - head_dir.rotated(PI/2) * head_width,
						])
	
	if !is_filled:
		head_points.push_back(draw_call.to)
		
	
	drawing_node.draw_line(
		draw_call.from,
		dest,
		draw_call.color, 
		1.0 if is_filled else draw_call.width, 
		draw_call.antialiased
	)
	
	if draw_call.width == -1:
		drawing_node.draw_colored_polygon(
			head_points, 
			draw_call.color
		)
	else: 
		drawing_node.draw_polyline(
			head_points, 
			draw_call.color,
			draw_call.width,
			draw_call.antialiased
		)
		
func _draw_rect(draw_call: RectDrawCall) -> void:
	drawing_node.draw_rect(
		draw_call.rect,
		draw_call.color,
		draw_call.width < 0, 
		draw_call.width, 
		draw_call.antialiased
	)
	
func _draw_circle(draw_call: CircleDrawCall) -> void:
	drawing_node.draw_circle(
		draw_call.origin,
		draw_call.radius,
		draw_call.color,
		draw_call.width < 0, 
		draw_call.width, 
		draw_call.antialiased
	)

func _draw() -> void:
	for draw_call: DrawCall in _batched_calls:
		if draw_call is LineDrawCall: _draw_line(draw_call)
		elif draw_call is PolygonDrawCall: _draw_polygon(draw_call)
		elif draw_call is ArrowDrawCall: _draw_arrow(draw_call)
		elif draw_call is RectDrawCall: _draw_rect(draw_call)
		elif draw_call is CircleDrawCall: _draw_circle(draw_call)
	
	
	
