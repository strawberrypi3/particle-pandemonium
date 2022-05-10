# For easily testing different levels
extends Control


var time = 0.0


onready var cursor_stage = Global.world_unlocked # Stage that the cursor (arrow) is currently pointing to

func _ready():
	$PopUp.hide()
	
	set_cursor_position(cursor_stage)
	
	update_selection_bar()
	
	$PeriodicTable/Waves.play("default")


func _physics_process(delta):
	time += delta
#	$ParallaxBackground/HexagonBackground.position = Vector2(60*time, 0)
	
	$PeriodicTable/Top.play(str(Global.world_unlocked))
	
	if Input.is_action_just_pressed("left"):
		if cursor_stage > 1:
			cursor_stage -= 1
			
			set_cursor_position(cursor_stage)
			
			update_selection_bar()
			
	if Input.is_action_just_pressed("right"):
		if cursor_stage < 10:
			cursor_stage += 1
			
			set_cursor_position(cursor_stage)
			
			update_selection_bar()
	
	if Input.is_action_just_pressed("enter"):
		if Global.world_unlocked >= cursor_stage: # level is unlocked
			choose_world(cursor_stage)


func update_selection_bar():
	if Global.world_unlocked < cursor_stage:
		$SelectionBar/SelectionBarSprite.play("Unavailable")
		$SelectionBar/Resume.hide()
		$SelectionBar/Start.show()
		$SelectionBar/Start.set("custom_colors/font_color", 
				Color(0.15, 0.15, 0.15)) # Gray
	elif Global.world_unlocked == cursor_stage:
		$SelectionBar/SelectionBarSprite.play("Yellow")
		if Global.level_unlocked > 1:
			$SelectionBar/Start.hide()
			$SelectionBar/Resume.show()
	else:
		$SelectionBar/SelectionBarSprite.play("Start")
		$SelectionBar/Resume.hide()
		$SelectionBar/Start.show()
		$SelectionBar/Start.set("custom_colors/font_color", 
				Color(0, 0, 0)) # Black


func choose_world(world_number):
	# Initialize global level values:
	var world_name = Global.worlds[int(world_number)]
	Global.world = world_number
	if world_number == Global.world_unlocked: # Furthest-unlocked world chosen
		Global.level_number = Global.level_unlocked
	else:
		Global.level_number = 1
	
	# Show pre-level popup and element-specific information:
	$PopUp.show()
	for label in get_tree().get_nodes_in_group("element_info"):
		label.hide()
	if (get_node_or_null(str("PopUp/", world_name[1].capitalize())) != 
			null):
		get_node(str("PopUp/", world_name[1].capitalize())).show()
	
	$PopUp/Nucleus.play(str(world_name[1].capitalize()))
	
	$PopUp/Nucleus/AnimationPlayer.play("rotate")
	
	# Hide other buttons:
	$SelectionBar.hide()
	$LeftArrow.hide()
	$RightArrow.hide()


func _on_ChallengeButton_pressed():
	pass


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
	$SelectionBar.show()
	$LeftArrow.show()
	$RightArrow.show()
