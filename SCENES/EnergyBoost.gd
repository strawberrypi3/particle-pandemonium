extends Area2D

signal collected

var activated = true

func _physics_process(delta):
	if activated:
		$AnimatedSprite.play("default")
		$AnimatedSprite.modulate = Color(1,1,1,1)
		set_collision_layer_bit(5, true)
	else:
		$AnimatedSprite.play("gray")
		$AnimatedSprite.modulate = Color(1,1,1,0.5)
		set_collision_layer_bit(5, false)


func _on_EnergyBoost_body_entered(body):
	activated = false
	emit_signal("collected")

