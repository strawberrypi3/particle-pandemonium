extends StaticBody2D


export var direction = Vector2.ZERO # direction that photon will be shot
export var interval = 2.0 # time between shooting photons
export var photon_speed = 700


func _ready():
	$Timer.wait_time = interval
	$Timer.start()


func _on_Timer_timeout():
	shoot_photon()
	$Timer.start()


func shoot_photon():
	var photon = preload("res://SCENES/photon.tscn")
	photon = photon.instance()
	photon.direction = self.direction
	photon.speed = photon_speed
	add_child(photon)
