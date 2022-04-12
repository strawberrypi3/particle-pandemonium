extends Camera2D


export var follow_player = false


func _physics_process(delta):
	if follow_player:
		anchor_mode = ANCHOR_MODE_DRAG_CENTER
		position = get_parent().get_parent().get_node("Player").position



