# For easily testing different levels
extends Control

var stage = 5 # Incremented every time a level is completed for the first time
var cursor_stage = 1 # Stage that the cursor (arrow) is currently pointing to

var levels = {
		1 : ["hydrogen", "h"], 
		2 : ["helium", "he"], 
		3 : ["lithium", "li"], 
		4 : ["beryllium", "be"], 
		5 : ["boron", "b"],
		6 : ["carbon", "c"], 
		7 : ["nitrogen", "n"], 
		8 : ["oxygen", "o"],
		9 : ["flourine", "f"], 
		10 : ["neon", "ne"]}


func _ready():
	$PopUp.hide()
	
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
			choose_level(cursor_stage)
#			open_level(cursor_stage)


func choose_level(level_number):
	# Initialize global level values:
	var level_name = levels[level_number]
	Global.world = level_name[0]
	Global.world_abbrv = level_name[1]
	Global.level_number = 1
	
	# Show pre-level popup and element-specific information:
	$PopUp.show()
	for label in get_tree().get_nodes_in_group("element_info"):
		label.hide()
	if (get_node_or_null(str("PopUp/", level_name[1].capitalize())) != 
			null):
		get_node(str("PopUp/", level_name[1].capitalize())).show()
	
	$PopUp/Nucleus.play(str(level_name[1].capitalize()))
	
	$PopUp/Nucleus/AnimationPlayer.play("rotate")
	
	# Hide other buttons:
	$SelectionBarButton.hide()
	$SelectionBarSprite.hide()
	$LeftArrow.hide()
	$RightArrow.hide()


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


func _on_TouchScreenButton_pressed(): # Popup (second) play button
	get_tree().change_scene("res://SCENES/game.tscn")


func _on_XButton_pressed():
	$PopUp.hide()
	$SelectionBarButton.show()
	$SelectionBarSprite.show()
	$LeftArrow.show()
	$RightArrow.show()
