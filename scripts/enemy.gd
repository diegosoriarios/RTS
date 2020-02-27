extends KinematicBody2D

var speed = 100

var pos2d
var player
var dir
var timer
var turn = true
var rotationValue = 1
var can_shoot = true

onready var Bullet = preload("res://scenes/bullet.tscn")

func _ready():
	pos2d = Position2D.new()
	pos2d.position = self.position
	get_parent().add_child(pos2d)
	pass

func _physics_process(delta):
	if player:
		var m = player.position
		var aim_speed = deg2rad(1)
		if self.get_angle_to(m) > .1:
			self.rotation += aim_speed
		elif self.get_angle_to(m) < -.1:
			self.rotation -= aim_speed
		dir = (player.global_position - global_position).normalized()
		move_and_collide(dir * speed * delta)
		if can_shoot:
			shoot(player.position)
	else:
		#start_watch()
		dir = (pos2d.global_position - global_position).normalized()
		move_and_collide(dir * speed * delta)
		pass

func shoot(pos):
	var b = Bullet.instance()
	var a = (pos - global_position).angle()
	b.start(global_position, a + rand_range(-0.05, 0.05))
	get_parent().add_child(b)
	can_shoot = false
	$ShootTimer.start()

func _on_ShootTimer_timeout():
	can_shoot = true

func start_watch():
	self.rotation = deg2rad(rotationValue)
	if self.rotation_degrees < 90:
		rotationValue += 1
	else:
		rotationValue -= 1
	
	print(self.rotation_degrees)

func _on_Visibility_body_entered(body):
	print(body.name)
	if body.name != self.name:
		player = body


func _on_Visibility_body_exited(body):
	start_timer()

func start_timer():
	timer = Timer.new()
	timer.set_wait_time(2)
	timer.connect("timeout",self,"_on_timer_timeout") 
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	player = null
