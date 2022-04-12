# This script is universal for all levels.
#
# All levels MUST have:
# 	- an instance of a Door scene
# 	- a Node2D PlayerPosition that indicates where the player starts
#
# Key, FloorSwitch, EnergyBoost, ElectronSwitch, Gate, Pipe, and
# ElectricPlatform nodes are all covered in this script, so if they are added
# as children to a specific instance of a level, they should connect and
# function as intended. Level will still function without them.
#
# Specific levels that are more complicated may extend from this script (ex.
# boss fights)
extends Node2D

signal level_complete
signal shift_camera

# When set to true, camera scrolls following player instead of staying static:
export var follow_player = false

# Camera zoom when follow_player == true:
export var player_camera_zoom = Vector2(1,1)

# The bottom right point of the screen border when follow_player == true:
export var bottom_right_point = Vector2(1200, 2400)

# The top left point of the screen border when follow_player == true:
export var top_left_point = Vector2(0, 0)


func _ready():
	# Connect all necessary signals of instantiated nodes (which may or may
	# not be children)
	for child in get_children():
		if child.get_filename() == "res://SCENES/Key.tscn":
			child.connect("collected", self, "_on_Key_collected")
		
		if child.get_filename() == "res://SCENES/FloorSwitch.tscn":
			child.connect("pressed", self, "_on_FloorSwitch_pressed")
			child.connect("released", self, "_on_FloorSwitch_released")
			
		if child.get_filename() == "res://SCENES/EnergyBoost.tscn":
			child.connect("collected", get_parent(), "_on_EnergyBoost_collected")
		
		if child.get_filename() == "res://SCENES/ElectronSwitch.tscn":
			child.connect("entered", self, "_on_ElectronSwitch_entered")
			child.connect("exited", self, "_on_ElectronSwitch_exited")

	if !follow_player:
		$Camera2D.make_current()


func _on_Door_body_entered(body):
	# The following two checks prevent player from entering door upon instancing
	# level if door is in the same place as the player just was (nice sentence)
	if body.get_filename() == "res://SCENES/Player.tscn":
		if body.sensing: # This is set to false during level transitions
			emit_signal("level_complete")


func _on_Key_collected():
	$Door.locked = false


func _on_FloorSwitch_pressed(floor_switch_id):
	# Unlock gate(s) if ids match:
	for child in get_children():
		# Unlock gate:
		if child.get_filename() == "res://SCENES/Gate.tscn":
			if child.id == floor_switch_id:
				child.switch_pressed()
		# Change pipe color:
		if child.get_filename() == "res://SCENES/Pipe.tscn":
			if child.id == floor_switch_id:
				child.activated = true


func _on_FloorSwitch_released(floor_switch_id):
	# Lock gate(s) if ids match:
	for child in get_children():
		# Lock gate:
		if child.get_filename() == "res://SCENES/Gate.tscn":
			if child.id == floor_switch_id:
				child.switch_released()
		# Change pipe color:
		if child.get_filename() == "res://SCENES/Pipe.tscn":
			if child.id == floor_switch_id:
				child.activated = false


func _on_ElectronSwitch_entered(electron_switch_id):
	for child in get_children():
		if child.get_filename() == "res://SCENES/ElectricPlatform.tscn":
			if child.id == electron_switch_id:
				child.activate()


func _on_ElectronSwitch_exited(electron_switch_id):
	for child in get_children():
		if child.get_filename() == "res://SCENES/ElectricPlatform.tscn":
			if child.id == electron_switch_id:
				child.deactivate()


func reset_energy_boosts():
	for child in get_children():
		if child.get_filename() == "res://SCENES/EnergyBoost.tscn":
			child.activated = true
