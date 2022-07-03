extends Node

const SAVE_FILE = "user://savegame.json"

var world : int = 1
var worlds = {
		1 : ["hydrogen", "h"], 
		2 : ["helium", "he"], 
		3 : ["lithium", "li"], 
		4 : ["beryllium", "be"], 
		5 : ["boron", "b"],
		6 : ["carbon", "c"]}
		#7 : ["nitrogen", "n"], 
		#8 : ["oxygen", "o"],
		#9 : ["flourine", "f"], 
		#10 : ["neon", "ne"]}
var level_number = 1 # the current level number
var world_unlocked = 1 # the number of worlds unlocked
var level_unlocked = 1 # number of levels unlocked of the furthest world
var challenge_levels_completed = {1: false, 2: false, 3: false, 4: false, 
		5: false, 6: false, 7: false, 8: false, 9: false, 10: false}


func _ready():
	load_game()


func _physics_process(delta):
	
	# FOR TESTING ONLY:
	
	if Input.is_action_just_pressed("h"):
		get_tree().change_scene("res://SCENES/UI/world_map.tscn")
	
	if Input.is_action_just_pressed("q"):
		world_unlocked += 1
	
	if Input.is_action_just_pressed("o"):
		save_game()
	
	if Input.is_action_just_pressed("p"):
		load_game()
	
	if Input.is_action_just_pressed("m"):
		print(typeof(Global.world))


func world_complete():
	if Global.world_unlocked == Global.world:
		if Global.world_unlocked < 6:
			Global.world_unlocked += 1
		Global.level_unlocked = 1
		save_game()


func level_complete():
	if Global.world_unlocked == Global.world:
		Global.level_unlocked += 1
		save_game()


func export_to_dict():
	return {
		"world_unlocked": world_unlocked,
		"level_unlocked": level_unlocked,
		"challenge_levels_completed": challenge_levels_completed
	}


func save_game():
	var save_game = File.new()
	save_game.open(SAVE_FILE, File.WRITE)
	var save_data = export_to_dict()
	save_game.store_line(to_json(save_data))
	save_game.close()


func load_game():
	var save_game = File.new()
	if !save_game.file_exists(SAVE_FILE):
		print("Error - save file does not exist")
		return
	save_game.open(SAVE_FILE, File.READ)
	var input = save_game.get_as_text()
	var save_data = parse_json(save_game.get_line())
	world_unlocked = save_data.world_unlocked
	level_unlocked = save_data.level_unlocked
	challenge_levels_completed = save_data.challenge_levels_completed
	save_game.close()
	
	
