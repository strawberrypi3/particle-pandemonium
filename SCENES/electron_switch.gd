extends StaticBody2D

signal entered
signal exited

enum {
	ON,
	OFF
}

var body_count = 0 # amazing name
export var id = 0 # Must have matching id to a platform to connect

var state = OFF

var colors = {
	0 : Color.darkgreen,
	1 : Color.darkred,
	2 : Color.darkblue,
	3 : Color.chocolate,
	4 : Color.gold
}

func _ready():
	if id in colors:
		$AnimatedSprite.modulate = colors[id]


func _physics_process(delta):
#	if body_count > 0:
#		state = ON
#	else:
#		state = OFF
	
	match state:
		ON:
			$AnimatedSprite.play("on")
		OFF:
			$AnimatedSprite.play("off")
			

func _on_Area2D_body_entered(body):
#	body_count += 1
#	if body_count == 1: # if just became pressed
	emit_signal("entered", id)
	state = ON


func _on_Area2D_body_exited(body):
#	body_count -= 1
#	if body_count == 0: # if just became released
	emit_signal("exited", id)
	state = OFF

