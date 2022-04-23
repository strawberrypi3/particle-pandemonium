extends StaticBody2D

const BREAK_TIME = 1

var breaking = false


func _ready():
	print(breaking)


func _break():
	breaking = true
	$AnimatedSprite.play("break")


func _on_Hurtbox_body_entered(body):
	if body.get_filename() == "res://SCENES/player.tscn":
		if !body.sensing:
			return # bye bye function
	_break()


func _on_AnimatedSprite_animation_finished():
	if breaking:
		queue_free()
