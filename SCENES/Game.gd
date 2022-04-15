# Controls all aspects of a 2D stage
# Assumes presence of:
#  - Player
#  - UI
#  - Sidekick*
#    *will still work if Sidekick is not present
# This script also instances different levels based on their saved Node name.
# For example, it will automatically instance the level "H2" after recieving
# the signal that the level "H1" is complete.
extends Node

const CAMERA_TRANS_SPEED = 40 # speed (pixels/second) of camera during shifts

enum {
	PLAYER # When Player is in control
	SIDEKICK # When Sidekick is in control
}

var state = PLAYER
var global_delta

onready var current_level_path = generate_level_path(Global.world, 
		Global.world_abbrv, Global.level_number)
onready var current_level_instance = load(current_level_path).instance()


func _ready():
	set_level(load(current_level_path))


func _physics_process(delta):
	global_delta = delta
	# STATE MACHINE:
	match state:
		PLAYER:
			$Player.move_state(delta) # Player is controlled
			if get_node_or_null("Sidekick") != null:
				$Sidekick.follow_state(delta) # Sidekick follows
			$UI.regular_state(delta) # UI acts normally
			
		SIDEKICK:
			$Player.vibrate_state(delta) # Player vibrates
			if get_node_or_null("Sidekick") != null:
				$Sidekick.move_state(delta) # Sidekick is controlled
			$UI.countdown_state(delta) # UI counts down, "unstable" state
	
	if Global.world == "hydrogen":
		$UI/MobileControls/Switch.hide()

	if Input.is_action_just_pressed("reset"):
		transition(Global.level_number)

	# FOR TESTING CONVENIENCE (DELETE LATER):
	if Input.is_action_just_pressed("g"):
		transition(Global.level_number + 1)
	
	$UI.sidekick_in_range = $Sidekick.is_in_range


func _on_Player_to_sidekick():
	state = SIDEKICK
	if current_level_instance.follow_player:
#		$Sidekick/Camera2D.position = Vector2(0,0)
#		$Sidekick/Camera2D.global_position = $Player/Camera2D.global_position
		camera_transition($Player, $Sidekick)
		var distance = sqrt(pow($Player.position.x - $Sidekick.position.x, 2) +
				pow($Player.position.y - $Sidekick.position.y, 2))
		var time = distance / CAMERA_TRANS_SPEED # time = distance / speed
		yield(get_tree().create_timer(0.5), "timeout")
		$Sidekick/Camera2D.position = Vector2(0,0)
		$Sidekick/Camera2D.global_position = get_mid_viewport_position()
		yield(get_tree().create_timer(0.1), "timeout")
		$Sidekick/Camera2D.make_current()



func _on_UI_to_player():
	state = PLAYER
	current_level_instance.reset_energy_boosts()
	if current_level_instance.follow_player:
		$Player/Camera2D.make_current()


func _on_Sidekick_to_player():
	_on_UI_to_player()
	yield(get_tree().create_timer(0), "timeout") # Ensures that state has 
			# ALREADY been switched to PLAYER as a result of _in_UI_to_player()
	$UI.reset_timer()


func _on_Player_to_player():
	_on_Sidekick_to_player()


func camera_transition(start_node : Node, target_node : Node):
	$TransitionCamera.smoothing_enabled = false
	$TransitionCamera.global_position = get_mid_viewport_position()
	$TransitionCamera.smoothing_speed = CAMERA_TRANS_SPEED
	$TransitionCamera.smoothing_enabled = true
	$TransitionCamera.make_current()
	$TransitionCamera.global_position = target_node.position
	
#	$TransitionCamera.position = get_mid_viewport_position()
#	var start_pos = start_node.position
#	var distance = sqrt(pow(start_pos.x - target_node.position.x, 2) + pow(
#			start_pos.y - target_node.position.y, 2))
#	var duration = distance / 500 # some constant, change later
#	$TransitionCamera.make_current()
#	$TransitionCamera.global_position = target_node.position
##	$TransitionCamera/Tween.interpolate_property($TransitionCamera, "global_position", 
##			start_pos, target_node.position, duration, Tween.TRANS_SINE, 
##			Tween.EASE_OUT)
#	return duration


func get_mid_viewport_position():
	# Code from https://godotengine.org/qa/13740/get-camera-extents-rect-2d
	var ctrans = get_viewport().get_canvas_transform()
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	var view_size = get_viewport().get_visible_rect().size / ctrans.get_scale()
	var max_pos = min_pos + view_size
	var mid_pos = (min_pos + max_pos) / Vector2(2,2)
	return mid_pos


# Adds a level node of <param> path to top of scene tree (index 0), replacing 
# previous level if one existed.
func set_level(level):
	# Remove current level node if one exists:
	current_level_instance.queue_free()
	
	# Instance new level node:
	current_level_instance = level.instance()
	add_child(current_level_instance)
	move_child(current_level_instance, 0) # Moves level node up in scene tree
	
	# Set up camera settings based on level's exported vars:
	for node in [$Player, $Sidekick]:
		node.camera_zoom = current_level_instance.player_camera_zoom
		node.bottom_right_point = current_level_instance.bottom_right_point
		node.top_left_point = current_level_instance.top_left_point
		node.follow_player = current_level_instance.follow_player
	if current_level_instance.follow_player:
		$TransitionCamera.zoom = current_level_instance.player_camera_zoom
		$TransitionCamera.limit_right = current_level_instance.bottom_right_point.x
		$TransitionCamera.limit_bottom = current_level_instance.bottom_right_point.y
		$TransitionCamera.limit_left = current_level_instance.top_left_point.x
		$TransitionCamera.limit_top = current_level_instance.top_left_point.y
	
	# Set up player position and orientation correctly:
	var start_pos = current_level_instance.get_node("PlayerPosition").position
	$Player.position = start_pos
	# Player faces whichever direction has more screen space:
	if get_node_or_null("Level/Camera2D"):
		$Player/AnimatedSprite.flip_h = (start_pos.x > 
				$Level/Camera2D.zoom.x * 1200 / 2)
	else:
		$Player/AnimatedSprite.flip_h = start_pos.x > 600
	
	current_level_instance.connect("level_complete", self, 
			"_on_Level_level_complete")


# Upon recieving signal that the player completed the current level, set the
# level to the next level in the world
func _on_Level_level_complete():
	if state == PLAYER and !($Player.dying or $Sidekick.dying):
		transition(Global.level_number + 1)
	else:
		while state != PLAYER:
			yield(get_tree().create_timer(global_delta), "timeout")
		if !($Player.dying or $Sidekick.dying):
			transition(Global.level_number + 1)


# for convienience, returns a full path containing the desired world/level:
func generate_level_path(world_full, world_abbrv, level_number):
	return str("res://SCENES/LEVELS/", Global.world, "/", Global.world_abbrv, 
			Global.level_number, ".tscn")


# Transitions (through animation and resetting) to the beginning of a desired
# level (based on param level_number). Can transition to same current level.
func transition(new_level_number):
	state = PLAYER
	$Player.sensing = false
	$UI.set_button_visibility(false)
	$UI/CanvasLayer/BlackOverlay.show()
	$UI.reset_timer()
	$Player.can_move = false
	$Player/CollisionShape2D.disabled = true
	$Sidekick/Hurtbox/CollisionShape2D.disabled = true
	
	$UI/CanvasLayer/BlackOverlay/AnimationPlayer.play("SlideIn")
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	Global.level_number = new_level_number
	current_level_path = generate_level_path(Global.world, Global.world_abbrv, 
			Global.level_number)
	set_level(load(current_level_path))
	
	$UI/CanvasLayer/BlackOverlay/AnimationPlayer.play("SlideOut")
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	$Player.can_move = true
	$Player/CollisionShape2D.disabled = false
	$Sidekick/Hurtbox/CollisionShape2D.disabled = false
	$UI.set_button_visibility(true)
	$Player.sensing = true
	
	# Prevents extra buffer flicker frame between showing switch button (above)
	# and subsequently hiding it in _physics_process:
	if Global.world == "hydrogen":
		$UI/MobileControls/Switch.hide()


func _on_Player_death():
	$UI.set_button_visibility(false)
	$Player/CollisionShape2D.disabled = true
	$Sidekick/Hurtbox/CollisionShape2D.disabled = true
	yield(get_tree().create_timer(0.25), "timeout")
	transition(Global.level_number)
	yield(get_tree().create_timer(0.5), "timeout")
	$Player.dying = false


func _on_Sidekick_death():
	$UI.set_button_visibility(false)
	yield(get_tree().create_timer(0.25), "timeout")
	transition(Global.level_number)
	$UI/SidekickTimer.stop()
	$UI.timer_running = false # restarts the countdown
	yield(get_tree().create_timer(0.5), "timeout")
	$Sidekick.dying = false


func _on_EnergyBoost_collected():
	$UI.timer_running = false # restarts the countdown



