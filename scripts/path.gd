extends Path2D


onready var follow = $follow
onready var guard = $follow/Guard

func _ready():
	pass

func _process(delta):
	if !guard.target:
		follow.set_offset(follow.get_offset() + 50 * delta)
