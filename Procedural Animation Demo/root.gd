extends Spatial

onready var player = get_node("Entity")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var dir = Vector3.ZERO
	dir.z -= Input.get_action_strength("ui_down")
	dir.z += Input.get_action_strength("ui_up")
	player.transform.origin += dir * delta * 5.0
