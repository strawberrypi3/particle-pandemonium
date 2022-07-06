# For easily testing different levels
extends Control

const TRANSITION_TIME = 0.3 # time while camera moves between levels

var transitioning : bool = false
# Stage that the cursor (arrow) is currently pointing to:
var cursor_stage : int setget set_cursor_stage 
var background : int setget set_background
var popped_up : bool = false

func _ready():
	for child in $BGLayer.get_children():
		if child is Sprite or child is AnimatedSprite:
			child.modulate.a = 0
	$CanvasLayer/PopUp.hide()
	$BGLayer/Controls.show()
	
	set_camera_position(Global.world_unlocked, false)
	set_cursor_stage(Global.world_unlocked, false)
	
	$CanvasLayer/PeriodicTable/Waves.play("default")
	
	Audio.play("WorldMap")


func _physics_process(delta):
	$CanvasLayer/PeriodicTable/Top.play(str(Global.world_unlocked))
	
	if Input.is_action_just_pressed("left"):
		if popped_up: # hide popup
			$CanvasLayer/PopUp.hide()
			popped_up = false
		if cursor_stage > 1:
			set_cursor_stage(cursor_stage - 1)
		$BGLayer/Controls.hide()
		$BGLayer/Controls/Timer.start()
	
	if Input.is_action_just_pressed("right"):
		if popped_up: # hide popup
			$CanvasLayer/PopUp.hide()
			popped_up = false
		if cursor_stage < Global.world_unlocked:
			set_cursor_stage(cursor_stage + 1)
		$BGLayer/Controls.hide()
		$BGLayer/Controls/Timer.start()
	
	if Input.is_action_just_pressed("enter"):
		if popped_up:
			_on_TouchScreenButton_pressed()
		if Global.world_unlocked >= cursor_stage and not transitioning: # level is unlocked
			choose_world(cursor_stage)
		$BGLayer/Controls.hide()
		$BGLayer/Controls/Timer.start()


func set_cursor_stage(stage, animated : bool = true):
	if stage > 6 or stage < 1:
		return
	
	cursor_stage = stage
	
	if cursor_stage == 1:
		$CanvasLayer/PeriodicTable/Cursor.position = Vector2(30, 38)
	elif cursor_stage == 2:
		$CanvasLayer/PeriodicTable/Cursor.position = Vector2(270, 38)
	elif cursor_stage > 2 and cursor_stage <= 4: # Li or Be
		$CanvasLayer/PeriodicTable/Cursor.position = Vector2(30 + 
				20*(cursor_stage - 3), 58)
	elif cursor_stage > 4 and cursor_stage <= 10: # Between B and Ne
		$CanvasLayer/PeriodicTable/Cursor.position = Vector2(170 + 
				20*(cursor_stage - 5), 58)
	
	#$CanvasLayer/Right.show()
	#$CanvasLayer/Left.show()
	if cursor_stage == 1:
		$CanvasLayer/Left.hide()
	if cursor_stage == Global.world_unlocked:
		$CanvasLayer/Right.hide()

	
	set_camera_position(cursor_stage, animated)
	
	set_background(cursor_stage, animated)
	
	for i in 5:
		var connector = get_node_or_null("Map/LC" + str(i+1))
		if i+1 < Global.world_unlocked and connector:
			connector.modulate = Color("008d47")
		elif connector:
			connector.modulate = Color("636363")


func set_camera_position(stage : int, animated : bool = true):
	var target_position : Vector2
	var target = $Map.get_node_or_null(str(stage))
	if target:
		target_position = target.global_position
	
	if not animated:
		$Camera2D.position = target_position
	else:
		$Camera2D/Tween.interpolate_property($Camera2D, "position", 
				$Camera2D.position, target_position, TRANSITION_TIME, 
				Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Camera2D/Tween.start()
		transitioning = true


func set_background(stage : int, animated : bool = true):
	# get current background:
	var old = get_node_or_null("BGLayer/" + str(background))
	var new = get_node_or_null("BGLayer/" + str(stage))
	
	if old:
		$BGLayer/Tween.interpolate_property(old, "modulate", Color(1, 1, 1, 1), 
				Color(1, 1, 1, 0), TRANSITION_TIME)
	
	if new:
		$BGLayer/Tween.interpolate_property(new, "modulate", Color(1, 1, 1, 0), 
				Color(1, 1, 1, 1), TRANSITION_TIME)
	$BGLayer/Tween.start()
	
	background = stage


func choose_world(world_number : int):
	# Initialize global level values:
	var world_name = Global.worlds[int(world_number)]
	Global.world = world_number
	if world_number == Global.world_unlocked: # Furthest-unlocked world chosen
		Global.level_number = Global.level_unlocked
	else:
		Global.level_number = 1
	
	# Show pre-level popup and element-specific information:
	popped_up = true
	$CanvasLayer/PopUp.show()
	for label in get_tree().get_nodes_in_group("element_info"):
		label.hide()
	var element = get_node_or_null(str("CanvasLayer/PopUp/", 
			world_name[1].capitalize()))
	if element:
		element.show()
	
	$CanvasLayer/PopUp/Nucleus.play(str(world_name[1].capitalize()))
	
	$CanvasLayer/PopUp/Nucleus/AnimationPlayer.play("rotate")
	
	$CanvasLayer/Left.hide()
	$CanvasLayer/Right.hide()


func _on_ChallengeButton_pressed():
	pass


func _on_TouchScreenButton_pressed(): # Popup (second) play button
	Audio.stop()
	Audio.play("Level")
	get_tree().change_scene("res://SCENES/game.tscn")


func _on_XButton_pressed():
	$CanvasLayer/PopUp.hide()
#	$SelectionBar.show()
	set_cursor_stage(cursor_stage)
	popped_up = false


func _on_Button_pressed():
	if Global.world_unlocked >= cursor_stage and not transitioning: # level is unlocked
		choose_world(cursor_stage)


func _on_Tween_tween_completed(object, key):
	transitioning = false


func _on_Timer_timeout(): # timer to show moving instructions
	if not $CanvasLayer/PopUp.visible:
		$BGLayer/Controls.show()
