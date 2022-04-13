extends Area2D

signal collected

export var type = 2 # 1 for red, 2 for yellow


func _physics_process(delta):
	if type == 1:
		$AnimatedSprite.play("red")
	elif type == 2:
		$AnimatedSprite.play("yellow")

func _on_Key_body_entered(body):
	# The following two checks prevent player from collecting key upon
	# instancing level if player is in same place as the key just was
	if body.get_filename() == "res://SCENES/player.tscn":
		if !body.sensing:
			return # bye bye function
	emit_signal("collected")
	$AnimatedSprite/AnimationPlayer.play("collected")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "collected":
		queue_free()
