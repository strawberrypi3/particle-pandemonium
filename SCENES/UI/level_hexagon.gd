extends Sprite


func _ready():
	if Global.world_unlocked == int(name):
		modulate = Color.indianred
	elif Global.world_unlocked > int(name):
		modulate = Color.teal#Color("80ba62")
	elif Global.world_unlocked < int(name):
		modulate = Color.dimgray
