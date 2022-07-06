extends Area2D

export var locked = true

#signal level_complete

func _physics_process(delta):
	$CollisionShape2D.disabled = locked
	if locked:
		$AnimatedSprite.play("closed")
	else:
		$AnimatedSprite.play("open")
