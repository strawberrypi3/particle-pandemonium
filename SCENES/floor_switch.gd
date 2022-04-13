extends StaticBody2D

signal pressed
signal released

enum {
	UNPRESSED,
	PRESSED
}

var body_count = 0 # amazing name
export var id = 0 # Must have matching id to a gate to connect

var state = UNPRESSED


func _physics_process(delta):
	if body_count > 0:
		state = PRESSED
	else:
		state = UNPRESSED
	
	match state:
		UNPRESSED:
			$AnimatedSprite.play("unpressed")
			$TopCollisionShape2D.disabled = false
		PRESSED:
			$AnimatedSprite.play("pressed")
			$TopCollisionShape2D.disabled = true
		


func _on_TopSensor_body_entered(body):
	body_count += 1
	if body_count == 1: # if just became pressed
		emit_signal("pressed", id)


func _on_TopSensor_body_exited(body):
	body_count -= 1
	if body_count == 0: # if just became released
		emit_signal("released", id)
