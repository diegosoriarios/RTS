extends KinematicBody2D

var speed = 100

var player
var dir
var timer
var turn = true
var rotationValue = 1

func _ready():
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
	else:
		#start_watch()
		pass

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
