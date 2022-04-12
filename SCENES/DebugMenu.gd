# For easily testing different levels
extends Node2D


func _on_HydrogenButton_pressed():
	Global.world = "Hydrogen"
	Global.world_abbrv = "H"
	Global.level_number = 1
	get_tree().change_scene("res://SCENES/Game.tscn")


func _on_HeliumButton_pressed():
	Global.world = "Helium"
	Global.world_abbrv = "He"
	Global.level_number = 1
	get_tree().change_scene("res://SCENES/Game.tscn")


func _on_LithiumButton_pressed():
	Global.world = "Lithium"
	Global.world_abbrv = "Li"
	Global.level_number = 1
	get_tree().change_scene("res://SCENES/Game.tscn")


func _on_BerylliumButton_pressed():
	Global.world = "Beryllium"
	Global.world_abbrv = "Be"
	Global.level_number = 1
	get_tree().change_scene("res://SCENES/Game.tscn")
