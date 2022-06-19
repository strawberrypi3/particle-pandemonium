extends KinematicBody2D

var speed = 1000
var direction : Vector2 # will be normalized when necessary
var velocity : Vector2
var reflections = 1 # Number of times it will reflect before dissapearing


func _ready():
	direction = direction.normalized()
	rotate_to_direction()


func _physics_process(delta):
	rotate_to_direction()
	
	velocity = direction * Vector2(speed, speed)
	velocity = move_and_slide(velocity, direction)
	
	if get_slide_count() != 0:
		var collision = get_slide_collision(0)
		if collision.collider.get_collision_layer_bit(11): # plant
			collision.collider.get_parent().grow()
			queue_free()
		
		elif collision.collider.get_collision_layer_bit(10): # refractor
			refract(collision, collision.collider.num_refractions)
			collision.collider.trigger_cooldown()
			
		elif collision.collider.get_collision_layer_bit(1): # platform
			reflect(collision)
		
		else:
			queue_free()


func rotate_to_direction():
	var t = 0
	direction = direction.normalized() # for good measure
	t = atan2(direction.y, direction.x)
	rotation_degrees = t * 180 / PI


func reflect(collision : KinematicCollision2D):
	reflections -= 1
	if reflections < 0:
		queue_free()
	else:
		var axis = collision.normal
		direction = direction.bounce(axis)
	
		# Prevent double collision:
		velocity = direction * Vector2(speed, speed)
		velocity = move_and_slide(velocity, direction)


func refract(collision : KinematicCollision2D, num_refractions : int):
	var normal = collision.normal
	var rotated = Vector2(normal.y, -normal.x) # rotated 90 degrees clockwise
	var arc = atan2(rotated.y, rotated.x)
	var interval = 180.0 / (num_refractions + 1) # split into equal angles
	interval = deg2rad(interval)
	for a in num_refractions:
		var angle = interval * (a + 1) # in radians
		var total_arc = arc + angle
		var new_direction = Vector2(cos(total_arc), sin(total_arc))
		
		# Create new photon that follows new_direction's trajectory
		var photon = load("res://SCENES/photon.tscn")
		photon = photon.instance()
		photon.direction = new_direction
		photon.speed = self.speed
		photon.reflections = self.reflections
		photon.get_child(0).modulate = hue_shift(rad2deg(angle))
		get_parent().add_child(photon)
		photon.position = position
	
	queue_free()


func hue_shift(angle : float) -> Color:
	var r
	var b
	var g
	if angle <= 30:
		r = 1
		b = 0
		g = angle / 30.0
	elif angle <= 60:
		r = 1 - ((angle - 30) / 30.0)
		b = 0
		g = 1
	elif angle <= 90:
		r = 0
		b = (angle - 60) / 30.0
		g = 1
	elif angle <= 120:
		r = 0
		b = 1
		g = 1 - ((angle - 90) / 30.0)
	elif angle <= 150:
		r = (angle - 120) / 30.0
		b = 1
		g = 0
	elif angle <= 180:
		r = 1
		b = 1 - ((angle - 150) / 30.0)
		g = 0
	else:
		print("Could not convert to hue, angle too large")
		return Color(1,0,0)
	return Color(r,g,b)

