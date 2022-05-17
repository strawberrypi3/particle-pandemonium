extends KinematicBody2D

var speed = 1000
var direction : Vector2 # will be normalized when necessary
var velocity : Vector2


func _ready():
	# Rotate:
	var t = 0
	direction = direction.normalized() # for good measure
	t = atan2(direction.y, direction.x)
	rotation_degrees = t * 180 / PI



func _physics_process(delta):
	# Rotate:
	var t = 0
	direction = direction.normalized() # for good measure
	t = atan2(direction.y, direction.x)
	rotation_degrees = t * 180 / PI
	
	velocity = direction * Vector2(speed, speed)
	velocity = move_and_slide(velocity, direction)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision != null:
			# If collided with reflector, reflect:
			if collision.collider.get_collision_layer_bit(1): # platform
				reflect(collision)
			
			elif collision.collider.get_collision_layer_bit(10): # refractor
				refract(collision, 30)

		# If collided with plant, be absorbed:
			elif collision.collider.get_collision_layer_bit(11): # plant
				collision.collider.get_parent().grow()
				queue_free()
			
			else:
				queue_free()


func reflect(collision : KinematicCollision2D):
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
		var angle = interval * (a + 1) # radians
		var total_arc = arc + angle
		var new_direction = Vector2(cos(total_arc), sin(total_arc))
		
		# Create second "refracted" photon that moves along axis
		var photon = load("res://SCENES/photon.tscn")
		photon = photon.instance()
		photon.direction = new_direction
		photon.speed = self.speed
		get_parent().add_child(photon)
		
		# Set new photon position
		photon.position = position
	
	queue_free()


func _on_Area2D_body_entered(body):
	pass # Replace with function body.
