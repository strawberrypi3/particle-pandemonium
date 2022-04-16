extends Node

var world = "hydrogen"
var world_abbrv = "h"
var level_number = 1


func _physics_process(delta):
	if Input.is_action_just_pressed("h"):
		get_tree().change_scene("res://SCENES/debug_menu.tscn")
