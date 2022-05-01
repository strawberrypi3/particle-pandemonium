extends KinematicBody2D

const MAX_FLOAT = 10.0

export var start_position = Vector2(0,0)
export var end_position = Vector2(0,0)
export var duration = 1
export var type = 1 # 1 for green, 2 for red (w/ spikes)

var velocity = Vector2.ZERO

onready var tween_positions = [start_position, end_position]


func _ready():
	start_tween()
	set_collision_layer_bit(1, (type == 1)) # platform
	set_collision_layer_bit(3, (type == 2)) # enemy
	if type == 1:
		$AnimatedSprite.play("blue")
	elif type == 2:
		$AnimatedSprite.play("green")


func start_tween():
	$Tween.interpolate_property(self, "position", tween_positions[0], 
			tween_positions[1], duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	tween_positions.invert()
	start_tween()


func _physics_process(delta):
	var v_amp = MAX_FLOAT / abs(start_position.y - end_position.y + 1)
	velocity = Vector2(0, get_cos_height($FloatTimer.time_left, 
			$FloatTimer.wait_time, v_amp))
	$AnimatedSprite.position.y = velocity.y


# Returns the y-value of point x on a cosine graph of defined transformation
# (this is literally exactly the same as seen in sidekick.gd):
# 	param x - x-value of point
# 	param period - length of one complete cycle of the cosine graph
# 	param amplitude - amplitude (maximum or |minumum|) of graph
# 	return float y-value of the point that corresponds with given x-value
func get_cos_height(var x, var period, var amplitude):
	var frequency = 2*PI / period
#	print(amplitude * cos(frequency * x))
	return amplitude * cos(frequency * x)
