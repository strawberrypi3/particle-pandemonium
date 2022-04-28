extends StaticBody2D

const BREAK_TIME = 1

var breaking = false
export var ignore_platform = false


func _ready():
	$Hurtbox.set_collision_mask_bit(1, !ignore_platform)


func _break():
	breaking = true
	$AnimatedSprite.play("break")


func _on_Hurtbox_body_entered(body):
	if body.get_filename() == "res://SCENES/player.tscn": # prevents re-instance bug
		if !body.sensing:
			return
	_break()


func _on_AnimatedSprite_animation_finished():
	if breaking:
		queue_free()
