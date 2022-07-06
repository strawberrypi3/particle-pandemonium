extends Node

var level_pattern = -1

func play(audio_name : String):
	var stream = get_node_or_null(audio_name)
	if stream and not stream.playing:
		stream.play()


func stop(audio_name : String = ""):
	for child in get_children():
		if audio_name == child.name or audio_name.empty():
			child.stop()
	if audio_name == "" or audio_name.find("Level") == 0:
		level_pattern = -1
