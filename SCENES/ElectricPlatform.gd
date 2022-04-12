# A platform that moves back and forth between start_position and end_position
# when the activated() function is called, but when deactivated(), freezes in
# place. Activation handled by res://SCENES/LEVELS/Level.gd or other parent
# scene.
extends StaticBody2D

export var start_position = Vector2(0,0)
export var end_position = Vector2(0,0)
export var duration = 1.0 # time (s) to travel from start_position to end_position
export var id = 0 # Must match other objects to connect
export var trans_type = Tween.TRANS_SINE
export var ease_type = Tween.EASE_IN_OUT

var disabled = false

onready var tween_positions = [start_position, end_position]


func _ready():
	start_tween()
	deactivate()


func start_tween():
	$Tween.interpolate_property(self, "position", tween_positions[0], 
			tween_positions[1], duration, trans_type, ease_type)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	yield(get_tree().create_timer(0), "timeout")
	if !disabled:
		tween_positions.invert()
		start_tween()


func activate():
	disabled = false
	$Tween.resume(self)
	$AnimatedSprite.play("on")


func deactivate():
	disabled = true
	$Tween.stop(self)
	$AnimatedSprite.play("off")
