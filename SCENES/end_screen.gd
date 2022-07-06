extends Node2D


onready var world = Global.world


func _ready():
	print(world)
	for child in $Background.get_children():
		if child is Sprite or child is AnimatedSprite:
			if child.name == str(world):
				child.show()
			else:
				child.hide()
	$LevelPopUpWindowSmall/Body.text = format_text()


func _physics_process(delta):
	if Input.is_action_just_pressed("enter"):
		Audio.stop()
		get_tree().change_scene("res://SCENES/UI/world_map.tscn")


func format_text():
	var text = "You have witnessed the power of "
	text += Global.worlds[int(world)][0] + "!\n"
	if world < 6:
		text += "Press [ENTER] to continue your journey."
	else:
		text += "Well, that was the last level! At least for now.\nThanks for playing! ([ENTER] to return to menu)"
	return text
