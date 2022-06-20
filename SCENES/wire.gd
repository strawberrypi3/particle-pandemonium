extends TileMap

export var id : int = 0

var colors = {
	0 : Color.darkblue,
	1 : Color.cyan,
	2 : Color.darkred,
	3 : Color.chocolate,
	4 : Color.gold
}


func _ready():
	if id in colors:
		modulate = colors[id]
	modulate.a = 0.5
	if id == 1:
		modulate.a = 0.2

