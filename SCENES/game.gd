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

enum {
	PLAYER # When Player is in control
	SIDEKICK # When Sidekick is in control
}

var state = PLAYER
var global_delta

onready var current_level_path = generate_level_path(
		(Global.worlds[Global.world])[0], (Global.worlds[Global.world])[1], 
		Global.level_number)
onready var current_level_instance = load(current_level_path).instance()


func _ready():
	set_level(current_level_path)
	$MultitargetCamera.targets.append($Player)
	$MultitargetCamera.targets.append($Sidekick)
	$Player.sensing = false
	yield(get_tree().create_timer(0), "timeout")
	$Player.sensing = true


func _physics_process(delta):
	global_delta = delta
	# STATE MACHINE:
	match state:
		PLAYER:
			$Player.move_state(delta) # Player is controlled
			if get_node_or_null("Sidekick") != null:
				$Sidekick.follow_state(delta) # Sidekick follows
			$UI.regular_state(delta) # UI acts normally
			$MultitargetCamera.player_state(delta) # Camera only follows player
			
		SIDEKICK:
			$Player.vibrate_state(delta) # Player vibrates
			if get_node_or_null("Sidekick") != null:
				$Sidekick.move_state(delta) # Sidekick is controlled
			$UI.countdown_state(delta) # UI counts down, "unstable" state
			$MultitargetCamera.sidekick_state(delta) # Camera follows player and sidekick
	
	if Global.world == 1:
		$UI/MobileControls/Switch.hide()

	if Input.is_action_just_pressed("reset"):
		transition(Global.level_number)

	# FOR TESTING CONVENIENCE (DELETE LATER):
	if Input.is_action_just_pressed("g"):
		transition(Global.level_number + 1)
	
	
	$UI.sidekick_in_range = $Sidekick.is_within_threshold


func _on_Player_to_sidekick():
	state = SIDEKICK


func _on_UI_to_player():
	state = PLAYER
	current_level_instance.reset_energy_boosts()


func _on_Sidekick_to_player():
	_on_UI_to_player()
	yield(get_tree().create_timer(0), "timeout") # Ensures that state has 
			# already been switched to PLAYER as a result of _on_UI_to_player()
	$UI.reset_timer()


func _on_Player_to_player():
	_on_Sidekick_to_player()


# Adds a level node of <param> path to top of scene tree (index 0), replacing 
# previous level if one existed.
func set_level(level_path : String):
	# Remove current level node if one exists:
	current_level_instance.queue_free()
	
	var packed_level = load(level_path)
	
	# Instance new level node:
	if packed_level == null:
		Global.world_complete()
		get_tree().change_scene("res://SCENES/UI/world_map.tscn") # Replace with animation later
		return
	
	if (Global.level_number != Global.level_unlocked and 
			Global.world == Global.world_unlocked):
		Global.level_complete()
	
	current_level_instance = packed_level.instance()
	add_child(current_level_instance)
	move_child(current_level_instance, 0) # Moves level node up in scene tree
	
	if current_level_instance.follow_player:
		$MultitargetCamera.make_current()
		$MultitargetCamera.move_speed = current_level_instance.move_speed
		$MultitargetCamera.zoom_speed = current_level_instance.zoom_speed
		$MultitargetCamera.min_zoom = current_level_instance.min_zoom
		$MultitargetCamera.max_zoom = current_level_instance.max_zoom
		$MultitargetCamera.margin = current_level_instance.margin
		$MultitargetCamera.limit_rect = current_level_instance.limit_rect
	
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
	return str("res://SCENES/LEVELS/", world_full, "/", world_abbrv, 
			level_number, ".tscn")


# Transitions (through animation and resetting) to the beginning of a desired
# level (based on param level_number). Can transition to same current level.
func transition(new_level_number):
	state = PLAYER
	$MultitargetCamera.smoothing_enabled = false
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
	var current_world = Global.worlds[Global.world]
	current_level_path = generate_level_path(current_world[0], current_world[1], 
			Global.level_number)
	set_level(current_level_path)
	
	$UI/CanvasLayer/BlackOverlay/AnimationPlayer.play("SlideOut")
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	$Player.can_move = true
	$Player/CollisionShape2D.disabled = false
	$Sidekick/Hurtbox/CollisionShape2D.disabled = false
	$UI.set_button_visibility(true)
	$Player.sensing = true
	$MultitargetCamera.smoothing_enabled = true
	
	# Prevents extra buffer flicker frame between showing switch button (above)
	# and subsequently hiding it in _physics_process:
	if Global.world == 1:
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



