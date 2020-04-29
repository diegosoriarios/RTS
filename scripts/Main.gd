extends Node2D

var selected_units = [] # objects

var units = []

onready var button = preload("res://scenes/button.tscn")
onready var Bullet = preload("res://scenes/PlayerBullet.tscn")
onready var Item = preload("res://scenes/item.tscn")
const DB = preload("res://scripts/Inventory/ItemDB.gd")
onready var db = DB.new()
var buttons = [] # strings 
var view = load("res://assets/Cursor/eye.png")
var gun = load("res://assets/Cursor/focus.png")
var action = load("res://assets/Cursor/stop.png")
var knife = load("res://assets/Cursor/knife.png")
var cursor = load("res://assets/Cursor/cursor.png")

var current_action

onready var last_camera = $Camera2D
var inventory_is_open = false

func select_unit(unit):
	if not selected_units.has(unit):
		selected_units.append(unit)
	create_buttons()

func deselect_unit(unit):
	if selected_units.has(unit):
		selected_units.erase(unit)
	create_buttons()

func deselect_all():
	while selected_units.size() > 0:
		selected_units[0].set_selected(false)

func set_camera():
	if selected_units.size() > 0:
		selected_units[0].get_node("Camera2D").make_current()
		last_camera = selected_units[0].get_node("Camera2D")

func inventory_grid():
	var unit = selected_units[0]
	var grid = $UI.find_node("Control")
	grid.visible = true
	for item_name in unit.items:
		var item = Item.instance()
		var image = db.get_item(item_name).icon
		var img = Image.new()
		var texture = ImageTexture.new()
		img.load(image)
		texture.create_from_image(img)
		item.find_node("Sprite").texture = texture
		grid.find_node("GridContainer").add_child(item)
		print(item_name)

func inventory_group():
	pass

func create_buttons():
	if selected_units.size() == 1: inventory_grid()
	elif selected_units.size() > 1: inventory_group()
	delete_buttons()
	set_camera()
	for unit in selected_units:
		if not buttons.has(unit.name):
			var but = button.instance()
			but.connect_me(self, unit.name)
			but.rect_position = Vector2(buttons.size() * 64 + 32 , OS.window_size.y-70)
			$'UI/Base'.add_child(but)
			buttons.append(unit.name)

func delete_buttons():
	for but in buttons:
		if $'UI/Base'.has_node(but):
			var b = $'UI/Base'.get_node(but)
			b.queue_free()
			$'UI/Base'.remove_child(b)
	buttons.clear()

func was_pressed(obj):
	for unit in selected_units:
		if unit.name == obj.name:
			unit.set_selected(false)
			break


func get_units_in_area(area):
	var u = []
	for unit in units:
		if unit.position.x > area[0].x and unit.position.x < area[1].x:
			if unit.position.y > area[0].y and unit.position.y < area[1].y:
				u.append(unit)
	return u

func area_selected(obj):
	var start = obj.start
	var end = obj.end
	var area = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	var ut = get_units_in_area(area)
	if not Input.is_key_pressed(KEY_SHIFT):
		deselect_all()
	for u in ut:
		u.selected = not u.selected

func start_move_selection(obj):
	for un in selected_units:
		un.move_unit(obj.move_to_point)

func _ready():
	randomize()
	units = get_tree().get_nodes_in_group("units")

func _process(delta):
	
	if selected_units.size() == 0:
		$Camera2D.current = true
		$UI.find_node("Control").visible = false
	elif selected_units.size() == 1:
		var unit = selected_units[0]
		$Camera2D.position = unit.find_node("Camera2D").global_position
		
	
	if Input.is_action_just_pressed("inventory"):
		$Inventory.visible = !$Inventory.visible
		$Inventory.position = last_camera.position
		if $Inventory.visible:
			$Camera2D.current = true
			$UI/Base.visible = false
		else:
			last_camera.current = true
			$UI/Base.visible = true
	if selected_units.size() > 0:
		if Input.is_action_just_pressed("gun"): current_action = gun
		elif Input.is_action_just_pressed("view"): current_action = view
		elif Input.is_action_just_pressed("action"): current_action = action
		elif Input.is_action_just_pressed("knife"): current_action = knife
		
		if Input.is_mouse_button_pressed(BUTTON_RIGHT): current_action = cursor
		elif Input.is_mouse_button_pressed(BUTTON_LEFT):
			if current_action == gun:
				for u in selected_units:
					if u.can_shoot:
						var bullet = Bullet.instance()
						bullet.position = get_global_mouse_position()
						add_child(bullet)
						u.can_shoot = false
		
		Input.set_custom_mouse_cursor(current_action)
