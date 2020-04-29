extends Path2D


onready var follow = $follow

func _ready():
	pass

func _process(delta):
	follow.set_offset(follow.get_offset() + 50 * delta)
