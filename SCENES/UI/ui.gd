extends Control

enum {
	REGULAR
	COUNTDOWN
}

signal to_player

const TIME_BEFORE_SWITCH = 0.75
const COUNTDOWN_LENGTH = 6.0 # in seconds. Visual timer will still count from 5

var state = REGULAR
var timer_running = false
var switch_button_visible = true
var can_switch = false
var sidekick_in_range = false


func _ready():
	$CanvasLayer/BlackOverlay.hide()


func regular_state(delta):
	if switch_button_visible and sidekick_in_range:
		#$MobileControls/Switch.show()
		can_switch = true
	$MobileControls/Down.hide()
	$CanvasLayer/Numbers.hide()
	$CanvasLayer/ElectronOverlay.hide()
	
	modulate_arrow_buttons(1, 1, 1)


func countdown_state(delta):
	can_switch = false
	
	if !timer_running:
		$SidekickTimer.wait_time = COUNTDOWN_LENGTH
		$SidekickTimer.start()
		$CanvasLayer/ElectronOverlay/AnimationPlayer.stop()
		$CanvasLayer/ElectronOverlay/AnimationPlayer.playback_speed = (5 / 
				COUNTDOWN_LENGTH)
		$CanvasLayer/ElectronOverlay/AnimationPlayer.play("Rise")
		timer_running = true
	
	$MobileControls/Switch.hide()
	#$MobileControls/Down.show()
	$CanvasLayer/ElectronOverlay.show()
	
	$CanvasLayer/Numbers.show()
	$CanvasLayer/Numbers.play(str(int($SidekickTimer.time_left * (5 / 
			COUNTDOWN_LENGTH) + 1)))
	# Darkens color of number as the timer approaches 0:
	var percent_elapsed = $SidekickTimer.time_left / $SidekickTimer.wait_time
	$CanvasLayer/Numbers.modulate = Color(percent_elapsed, percent_elapsed, 0)
	
	modulate_arrow_buttons(1, 1, 0)


func modulate_arrow_buttons(red, blue, green):
	var buttons = get_tree().get_nodes_in_group("arrow_button")
	for i in buttons:
		i.modulate = Color(red, blue, green, 100.0/250.0)


func set_button_visibility(visibility : bool): # true = show, false = hide
	#var buttons = get_tree().get_nodes_in_group("arrow_button")
	#buttons.append($MobileControls/Switch)
	#for i in buttons:
	#	i.visible = visibility
	switch_button_visible = visibility
	
	# Prevents extra buffer flicker frame between showing down button here and 
	# subsequently hiding it in _physics_process:
	#if state == REGULAR:
		#$MobileControls/Down.hide()


func _on_SidekickTimer_timeout():
	emit_signal("to_player")
	timer_running = false


# Call during _regular_state() to avoid weird behavior
func reset_timer():
	timer_running = false
