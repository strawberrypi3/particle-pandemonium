extends Node

var world = "Hydrogen"
var world_abbrv = "H"
var level_number = 1


func _physics_process(delta):
	if Input.is_action_just_pressed("h"):
		get_tree().change_scene("res://SCENES/DebugMenu.tscn")
