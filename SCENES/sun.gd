extends StaticBody2D


export var direction = Vector2.ZERO # direction that photon will be shot
export var interval = 2.0 # time between shooting photons
export var start_time = 2.0 # time before first photon is shot
export var photon_speed = 200
export var num_reflections : = 1 # number of photon bounces before dissapearing


func _ready():
	$Timer.wait_time = start_time
	$Timer.start()


func _on_Timer_timeout():
	shoot_photon()
	$Timer.wait_time = interval
	$Timer.start()


func shoot_photon():
	var photon = preload("res://SCENES/photon.tscn")
	photon = photon.instance()
	photon.direction = self.direction
	photon.speed = photon_speed
	photon.reflections = num_reflections
	add_child(photon)
