extends Camera2D

var move_speed = 0.5 # camera position lerp speed
var zoom_speed = 0.25 # camera zoom lerp speed
var min_zoom = 1.5 # camera won't zoom closer than this
var max_zoom = 5 # camera won't move further than this
var margin = Vector2(400, 200) # include some buffer area around targets
var limit_rect = Rect2(Vector2.ZERO, Vector2.ZERO) setget set_limits

var targets = [] # Array of targets to be tracked.

onready var screen_size = get_viewport_rect().size


func player_state(delta):
	position = lerp(position, targets[0].position, move_speed)
	zoom = lerp(zoom, Vector2(min_zoom, min_zoom), zoom_speed / 5)


func sidekick_state(delta):
	if !targets:
		return
	
	# Keep the camera centered between the targets
	var p = Vector2.ZERO
	for target in targets:
		p += target.position
	p /= targets.size() # p is the average point between all target positions
	position = lerp(position, p , move_speed)
	
	# Find the zoom that will contain all targets
	var r = Rect2(position, Vector2.ONE) # a rectangle that encloses all targets
	for target in targets:
		r = r.expand(target.position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	var d = max(r.size.x, r.size.y)
	var z
	if r.size.x > r.size.y * screen_size.aspect():
		z = clamp(r.size.x / screen_size.x, min_zoom, max_zoom)
	else:
		z = clamp(r.size.y / screen_size.y, min_zoom, max_zoom)
	zoom = lerp(zoom, Vector2.ONE * z, zoom_speed)


func set_limits(new_limits):
	limit_left = new_limits.position.x
	limit_top = new_limits.position.y
	limit_right = new_limits.size.x
	limit_bottom = new_limits.size.y


func add_target(t):
	if not t in targets:
		targets.append(t)


func remove_target(t):
	if t in targets:
		targets.erase(t)
