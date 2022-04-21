# For easily testing different levels
extends Node2D


func _on_HydrogenButton_pressed():
	Global.world = "hydrogen"
	Global.world_abbrv = "h"
	Global.level_number = 1
	get_tree().change_scene("res://SCENES/game.tscn")


func _on_HeliumButton_pressed():
	Global.world = "helium"
	Global.world_abbrv = "he"
	Global.level_number = 1
	get_tree().change_scene("res://SCENES/game.tscn")


func _on_LithiumButton_pressed():
	Global.world = "lithium"
	Global.world_abbrv = "li"
	Global.level_number = 1
	get_tree().change_scene("res://SCENES/game.tscn")


func _on_BerylliumButton_pressed():
	Global.world = "beryllium"
	Global.world_abbrv = "be"
	Global.level_number = 1
	get_tree().change_scene("res://SCENES/game.tscn")


func _on_ChallengeButton_pressed():
	Global.world = "challenge"
	Global.world_abbrv = "c_h"
	Global.level_number = 1
	get_tree().change_scene("res://SCENES/game.tscn")
