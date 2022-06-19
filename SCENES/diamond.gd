extends StaticBody2D

export var num_refractions : int = 4 # number of photons that refract
export var cooldown = 0.0 # time before another refraction can occur


func trigger_cooldown():
	$CooldownTimer.wait_time = cooldown
	set_collision_layer_bit(10, false)
	$CooldownTimer.start()


func _on_CooldownTimer_timeout():
	set_collision_layer_bit(10, true)
