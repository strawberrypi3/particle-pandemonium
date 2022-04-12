extends AnimatedSprite

export var max_shift = Vector2(0,0)
export var start_position = Vector2(0,0)
export var duration = 0.0

onready var tween = Tween.new()

func _ready():
	play("default")
	
	add_child(tween)
	tween.connect("tween_completed", self, "_on_tween_completed")
	start_tween()


func start_tween():
	tween.interpolate_property(self, "position", start_position - max_shift, 
			start_position + max_shift, duration, Tween.TRANS_SINE, 
			Tween.EASE_IN_OUT)
	tween.start()


func _on_tween_completed(object, key):
	max_shift *= -1
	start_tween()
