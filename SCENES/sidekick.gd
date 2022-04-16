# State machine is controlled by res://SCENES/game.gd
# A Player node MUST be present!
# Sidekick follows behind the Player by default, and can be switched to a 
# controllable state.
extends KinematicBody2D

signal death
signal to_player

# FOLLOW state constants:
const VELOCITY_MULTIPLIER = 0.5*4
const MAX_H_DRIFT = 90*4
const MAX_V_DRIFT = 40*4

# MOVE state constants:
const MAX_SPEED = 80*4
const ACCELERATION = 600*4

const RANGE = 200 # Range (pxls) that sidekick must be within in order to switch

enum {
	FOLLOW,
	MOVE
}

var state = FOLLOW
var velocity = Vector2(0,0)
var drift_offset = Vector2(0,0)
var accepts_control = false
var wall_count = 0 # +1 every time a wall is entered, -1 when one is exited
var button_count = 0 # Wall count but for ButtonTouchOverride
var is_within_threshold
var is_in_wall = false
var dying = false

onready var target = get_parent().get_node("Player")


func _physics_process(delta):
	is_in_wall = wall_count > 0
	$Control/TouchScreenButton.visible = button_count < 1
	is_within_threshold = check_range(RANGE)


func follow_state(delta):
	accepts_control = false
	$CollisionShape2D.disabled = true
	$Hurtbox/CollisionShape2D.disabled = true
	
	$AnimatedSprite.play("default")
	if !dying:
		show()
	
	# Sets velocity relative to target position, thus allowing this object to
	# follow after the target when movement is enabled:
	velocity = (target.position - position) * Vector2(VELOCITY_MULTIPLIER, 
			VELOCITY_MULTIPLIER)
	
	# Applies the "drifting" motion
	drift_offset = get_drift_offset($VerticalDrift, $HorizontalDrift, 
			MAX_V_DRIFT, MAX_H_DRIFT)
	
	velocity = move_and_slide(velocity + drift_offset)
	
	if velocity.x > 0:
		$AnimatedSprite.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite.flip_h = true


func move_state(delta):
	if !accepts_control:
		if !check_range(20) and is_in_wall: # if player is outside threshold
			velocity = (target.position - position) * 5 # zip to player
		else:
			accepts_control = true
	
	
	if accepts_control:
		$CollisionShape2D.disabled = false
		$Hurtbox/CollisionShape2D.disabled = false
		
		# Controls:
		if Input.is_action_pressed("left"):
			velocity.x = move_toward(velocity.x, -MAX_SPEED, ACCELERATION
					* delta)
			$AnimatedSprite.flip_h = true
		elif Input.is_action_pressed("right"):
			velocity.x = move_toward(velocity.x, MAX_SPEED, ACCELERATION
					* delta)
			$AnimatedSprite.flip_h = false
		else:
			velocity.x = lerp(velocity.x, 0, 0.25) # velocity.x /= 4 every frame
		
		if Input.is_action_pressed("up"):
			velocity.y = move_toward(velocity.y, -MAX_SPEED, ACCELERATION
					* delta)
		elif Input.is_action_pressed("down"):
			velocity.y = move_toward(velocity.y, MAX_SPEED, ACCELERATION
					* delta)
		else:
			velocity.y = lerp(velocity.y, 0, 0.25) # velocity.y /= 4 every frame
		
		if Input.is_action_just_pressed("switch"):
			emit_signal("to_player")
	
	if !dying:
		velocity = move_and_slide(velocity, Vector2.UP)
		$AnimatedSprite.play("default")
		show()
	else: # if dying
		$AnimatedSprite.play("death")
		if $AnimatedSprite.frame == 5:
			hide()


# Returns the y-value of point x on a cosine graph of defined transformation:
# 	param x - x-value of point
# 	param period - length of one complete cycle of the cosine graph
# 	param amplitude - amplitude (maximum or |minumum|) of graph
# 	return float y-value of the point that corresponds with given x-value
func get_cos_height(var x, var period, var amplitude):
	var frequency = 2*PI / period
	return amplitude * cos(frequency * x)


# Generates a Vector2 that represents this object's drift offset from the
# expected path at a single frame:
# 	param v_timer - timer node whose length is the v-shift's period
# 	param h_timer - timer node whose length is the h-shift's period
# 	param v_amp - vertical amplitude
# 	param h_amp - horizontal amplitude
# 	return Vector2 that represents drift offset
func get_drift_offset(var v_timer, var h_timer, var v_amp, var h_amp):
	var new_vector = Vector2(0,0)
	new_vector.y = get_cos_height(v_timer.time_left, v_timer.wait_time, v_amp)
	new_vector.x = (get_cos_height(h_timer.time_left, h_timer.wait_time, h_amp)
			/ (target.velocity.length()/20 + 1)) # Less X offset when moving left/right
	return new_vector


func _on_Hurtbox_body_entered(body):
	dying = true
	emit_signal("death")


func _on_WallSensor_body_entered(body):
	wall_count += 1


func _on_WallSensor_body_exited(body):
	wall_count -= 1


func _on_Hurtbox_area_entered(area):
	if area.get_filename() == "res://SCENES/button_touch_override.tscn":
		button_count += 1
		return
	_on_Hurtbox_body_entered(area)


func _on_Hurtbox_area_exited(area):
	if area.get_filename() == "res://SCENES/button_touch_override.tscn":
		button_count -= 1


func check_range(threshold):
	return abs(position.x - target.position.x) <= threshold and abs(position.y 
			- target.position.y) <= threshold


func _on_TouchScreenButton_pressed():
	if accepts_control:
		emit_signal("to_player")



