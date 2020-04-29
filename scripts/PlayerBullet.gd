extends Area2D

var frame = 0

func _ready():
	pass

func _process(delta):
	frame += delta * 10
	
	print(frame)
	
	if frame > 1:
		queue_free()
	
	var bodies = get_overlapping_bodies()
	var to_alert = $Alert.get_overlapping_bodies()

	for body in bodies:
		if !body.is_in_group("units"):
			body.hit()
	
	for alert in to_alert:
		if alert.is_in_group("enemy"):
			alert.alert(position)
