extends StaticBody2D

export var id = 0 # Must have a matching id to a switch to connect
export var starts_open = false
onready var locked = !starts_open


func _physics_process(delta):
	$CollisionShape2D.disabled = !locked
	if locked:
		$AnimatedSprite.play("closed")
	else:
		$AnimatedSprite.play("open")


func switch_released():
	locked = !starts_open


func switch_pressed():
	locked = starts_open
