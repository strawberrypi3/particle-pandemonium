extends Control


func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://SCENES/UI/world_map.tscn")


func _on_Timer_timeout():
	$TapToStart.visible = !$TapToStart.visible
