# For easily testing different levels
extends Node2D

var stage = 4 # Incremented every time a level is completed for the first time
var cursor_stage = 1 # Stage that the cursor (arrow) is currently pointing to


func _ready():
	set_cursor_position(cursor_stage)
	
	if stage < cursor_stage:
		$SelectionBarSprite.play("Unavailable")
	else:
		$SelectionBarSprite.play("Start")


func _physics_process(delta):
	$PeriodicTable/Top.play(str(stage))
	
	if Input.is_action_just_pressed("left"):
		if cursor_stage > 1:
			cursor_stage -= 1
			
			set_cursor_position(cursor_stage)
			
			if stage < cursor_stage:
				$SelectionBarSprite.play("Unavailable")
			else:
				$SelectionBarSprite.play("Start")
			
	if Input.is_action_just_pressed("right"):
		if cursor_stage < 10:
			cursor_stage += 1
			
			set_cursor_position(cursor_stage)
			
			if stage < cursor_stage:
				$SelectionBarSprite.play("Unavailable")
			else:
				$SelectionBarSprite.play("Start")
	
	if Input.is_action_just_pressed("enter"):
		if stage >= cursor_stage: # level is unlocked
			open_level(cursor_stage)


func open_level(level_number):
	# Maybe replace the following with dictionary stuff, or at least rename the
	# functions
	if level_number == 1:
		_on_HydrogenButton_pressed()
	elif level_number == 2:
		_on_HeliumButton_pressed()
	elif level_number == 3:
		_on_LithiumButton_pressed()
	elif level_number == 4:
		_on_BerylliumButton_pressed()


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


func set_cursor_position(current_stage):
	if current_stage == 1:
		$Cursor.position = Vector2(120, 152)
	elif current_stage == 2:
		$Cursor.position = Vector2(1080, 152)
	elif current_stage > 2 and current_stage <= 4: # Li or Be
		$Cursor.position = Vector2(120 + 80*(current_stage - 3), 232)
	elif current_stage > 4 and current_stage <= 10: # Between B and Ne
		$Cursor.position = Vector2(680 + 80*(current_stage - 5), 232)

