extends Control


var path : String
var text_speed : float = 0.05
var dialog
var phrase_number : int = 0
var finished : bool = false


func _ready():
	$Timer.wait_time = text_speed
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()


func _process(delta):
	$Indicator.visible = finished
	if Input.is_action_just_pressed("enter"):
		if finished:
			nextPhrase()
		else:
			$Text.visible_characters = len($Text.text)


func getDialog() -> Array:
	var f = File.new()
	assert(f.file_exists(path), "File path does not exist")
	
	f.open(path, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []


func nextPhrase() -> void:
	if phrase_number >= len(dialog):
		hide()
		phrase_number = -1
		return
	
	finished = false
	
	$Name.bbcode_text = dialog[phrase_number]["Name"]
	$Text.bbcode_text = dialog[phrase_number]["Text"]
	
	set_box_color()
	
	$Text.visible_characters = 0
	
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		
		$Timer.start()
		yield($Timer, "timeout")
	
	finished = true
	phrase_number += 1
	return


func set_box_color():
	var speaker = dialog[phrase_number]["Name"]
	if speaker == "ELECTRON":
		$DialogBox.modulate = Color.yellow
	elif speaker == "PROTON":
		$DialogBox.modulate = Color.red
	else:
		$DialogBox.modulate = Color(1, 1, 1)
