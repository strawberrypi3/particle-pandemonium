extends KinematicBody2D

export var start_position = Vector2(0,0)
export var end_position = Vector2(0,0)
export var duration = 1
export var type = 1 # 1 for blue, 2 for green (w/ spikes)

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

