extends TileMap

export var id = 0 # must match with switch to light up

var activated = false


func _physics_process(delta):
	if activated:
		modulate = Color(211/255.0, 198/255.0, 0, 95/255.0)
	else:
		modulate = Color(211/255.0, 198/255.0, 1, 95/255.0)
