# State machine is controlled by res://SCENES/game.gd
extends KinematicBody2D

signal to_sidekick
signal death
signal to_player

const MAX_SPEED = 80*4 # per frame
const GRAVITY = 8*4
const JUMPFORCE = 230*4
const ACCELERATION = 600*4
const MAX_VIBRATION = 1*4*3 # Max displacement (pixels) when vibrating
const JUMP_BUFFER = 5 # Length (in numbers of frames) of jump buffer
const COYOTE_TIME = 0.14 # Length (in seconds) of coyote time

enum {
	MOVE,
	VIBRATE
}

var state = MOVE
var velocity = Vector2(0,0)
var actual_position = Vector2(0,0)
var dying = false
var can_move = true
var is_on_switch = false
var vibrating = false
var button_count = 0 # +1 if player enters ButtonTouchOverride, -1 for exit
var sensing = true # don't delete, used by Key, Game, and Door
var coyote_timer = 0
var buffer_frames_left = 0
var can_jump = false


func _physics_process(delta):
	$Control/TouchScreenButton.visible = button_count < 1


func move_state(delta):
	vibrating = false
	$AnimatedSprite.position = Vector2(0,0)
	$CollisionShape2D.disabled = false
	
	# Gravity:
	velocity.y += GRAVITY
	if velocity.y > 0: # Moving down
		velocity.y += GRAVITY / 3 # Increases gravity when moving down
	
	# Jump (implements coyote time and jump buffer):
	if is_on_floor():
		coyote_timer = 0
	
	if buffer_frames_left > 0:
		if is_on_floor():
			jump()
		else:
			buffer_frames_left -= 1
	elif Input.is_action_just_pressed("up"):
		if is_on_floor() or (coyote_timer <= COYOTE_TIME) or is_on_switch:
			jump()
		else:
			buffer_frames_left = JUMP_BUFFER
	
	if can_jump:
		velocity.y = -JUMPFORCE
		coyote_timer = COYOTE_TIME
#		buffer_timer = JUMP_BUFFER
	coyote_timer += delta
	
	# Scale jump to button holding time:
	if Input.is_action_just_released("up") and velocity.y < -260:
	# if player is moving upwards at a speed greater than 260 pps when up button
	# is released, limit their upwards velocity down to 260 (more natural than 0)
		velocity.y = -260

	# Switch directions:
	if Input.is_action_pressed("left") and not dying:
		velocity.x = move_toward(velocity.x, -MAX_SPEED, ACCELERATION * delta)
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("walking")
	elif Input.is_action_pressed("right") and not dying:
		velocity.x = move_toward(velocity.x, MAX_SPEED, ACCELERATION * delta)
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("walking")
	elif not dying:
		velocity.x = lerp(velocity.x, 0, 0.25) # velocity.x /= 4 every frame
		$AnimatedSprite.play("idle")
	
	if can_move:
		velocity = move_and_slide(velocity, Vector2.UP)
	
	actual_position = position
	
	
	if Input.is_action_just_pressed("switch") and !dying:
		var ui = get_parent().get_node("UI")
		if ui.can_switch == true:
			emit_signal("to_sidekick")
	
	if dying:
		$AnimatedSprite.play("death")
		if $AnimatedSprite.frame == 8:
			hide()
	else:
		show()


func jump():
	velocity.y = -JUMPFORCE
	coyote_timer = COYOTE_TIME


func vibrate_state(delta):
	vibrating = true
	randomize_position(position)
	
	if can_move:
		move_and_slide(Vector2(0,0), Vector2.UP)


# Sets player to a random x and y position within the boundaries of +/- MAX_
# VIBRATION.
# 	param actual_position - The actual, "locked" center position of the object.
# 							Must be the same every frame this method is
# 							continuously called in order to work correctly.
func randomize_position(var actual_position):
	randomize()
	var random_x = randf() * 2*MAX_VIBRATION - MAX_VIBRATION
	randomize()
	var random_y = randf() * 2*MAX_VIBRATION - MAX_VIBRATION
	$AnimatedSprite.position = (position - 
			(actual_position + Vector2(random_x/4, random_y/4)))


func _on_Hurtbox_body_entered(body):
	if (body.get_filename() == "res://SCENES/electron_switch.tscn" or 
			body.get_filename() == "res://SCENES/brittle_platform.tscn"):
		return
	dying = true
	can_move = false
	emit_signal("death")


func _on_Hurtbox_area_entered(area):
	# if the area was a floor switch
	if area.get_parent().get_filename() == "res://SCENES/floor_switch.tscn":
		is_on_switch = true
	if area.get_filename() == "res://SCENES/button_touch_override.tscn":
		button_count += 1
	


func _on_Hurtbox_area_exited(area):
	# if the area was a floor switch
	if area.get_parent().get_filename() == "res://SCENES/floor_switch.tscn":
		is_on_switch = false
	if area.get_filename() == "res://SCENES/button_touch_override.tscn":
		button_count -= 1


func _on_TouchScreenButton_pressed():
	if vibrating:
		emit_signal("to_player")
