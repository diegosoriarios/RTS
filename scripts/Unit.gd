extends KinematicBody2D

export var speed = 100

var selected = false setget set_selected
onready var box = $box
onready var bar = $bar
onready var label = $label_name

export (int) var detect_radius
export (float) var fire_rate
var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)

var move_p = false
var to_move = Vector2()
var path = PoolVector2Array()
var initialposition = Vector2()
#onready var raycast = $RayCast2D
var target
var hit_pos
var can_shoot = false

var items = ["potato"]

var gridContainer
var controlContainer

signal was_selected
signal was_deselected

func set_selected(value):
	if selected != value:
		selected = value
		box.visible = value
		label.visible = value
		bar.visible = value
		if selected:
			emit_signal("was_selected", self)
		else:
			emit_signal("was_deselected", self)

func _ready():
	gridContainer = get_parent().find_node("UI").find_node("Base").find_node("Control").find_node("GridContainer")
	controlContainer = get_parent().find_node("UI").find_node("Base").find_node("Control")
	connect("was_selected", get_parent(), "select_unit")
	connect("was_deselected", get_parent(), "deselect_unit")
	box.visible = false
	label.visible = false
	bar.visible = false
	label.text = name
	bar.value = randi() % 90 + 10

func _process(delta):
	if move_p:
		path = get_viewport().get_node("Main/nav").get_simple_path(position, to_move+Vector2(randi()%100, randi()%100))
		initialposition = position
		move_p = false
	if path.size() > 0:
		move_towards(initialposition, path[0], delta)
	
	$Visibility.look_at(get_global_mouse_position())
	
	update()
	if target:
		aim()
	else:
		rotation = 0

func move_towards(pos, point, delta):
	var v = (point - pos).normalized()
	v *= delta * speed
	position += v
	if position.distance_squared_to(point) < 9:
		path.remove(0)
		initialposition = position

func move_unit(point):
	to_move = point
	move_p = true

func _on_unit_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				set_selected(not selected)

func _draw():
	#draw_circle(Vector2(), detect_radius, vis_color)
	if target:
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), 5, laser_color)
			draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)

func aim():
	hit_pos = []
	var space_state = get_world_2d().direct_space_state	
	var target_extents = target.get_node('CollisionShape2D').shape.extents - Vector2(5, 5)
	var nw = target.position - target_extents
	var se = target.position + target_extents
	var ne = target.position + Vector2(target_extents.x, -target_extents.y)
	var sw = target.position + Vector2(-target_extents.x, target_extents.y)
	for pos in [target.position, nw, ne, se, sw]:
		var result = space_state.intersect_ray(position,
				pos, [self], collision_mask)
		if result:
			hit_pos.append(result.position)
			#if result.collider.name == "unit":
			if result.collider.is_in_group("enemy"):
				rotation = (target.position - position).angle()
				can_shoot = true
				break


func _on_Visibility_body_entered(body):
	if body.is_in_group("enemy"):
		print(body.name)
		if target:
			return
		target = body


func _on_Visibility_body_exited(body):
	if body == target:
		target = null
