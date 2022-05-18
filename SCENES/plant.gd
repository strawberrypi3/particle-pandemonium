extends Node2D


export var height : = 2 # Number of stem tiles of height


func _ready():
	if height == 0:
		$Top.hide()
		$Top/CollisionShape2D.disabled = true
		$Pot/AnimatedSprite.play("empty")
	else:
		var temp = height
		height = 0
		for i in temp:
			grow()


func grow():
	height += 1
	
	if height > 0:
		$Pot/AnimatedSprite.play("full")
	
	# Raise top:
	if height == 1:
		$Top.position = Vector2(16, -80)
		$Top.show()
		$Top/CollisionShape2D.disabled = false
	else:
		$Top.position.y -= 32
	
	# Stem:
	if height > 1:
		$Stem.set_cell(0, -1 - height, 0)
