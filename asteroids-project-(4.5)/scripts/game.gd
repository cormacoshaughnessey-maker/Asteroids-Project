extends Node2D

@onready var lasers := $Lasers
@onready var player := $Player
@onready var asteroids := $Asteroids
@onready var hud := $UI/HUD
@onready var player_spawn_pos := $PlayerSpawnPos
@onready var game_over_screen := $UI/GameOverScreen
@onready var player_spawn_area := $PlayerSpawnPos/PlayerSpawnArea
@onready var asteroid_spawn_area := $AsteroidSpawnArea
@onready var name_input := $UI/NameInput
@onready var pause_menu := $UI/PauseMenu
@onready var score_board := $UI/ScoreBoard

var high_score_list : Dictionary
var high_score_player : String
var player_name := "BBB"
var minimum_asteroids := 0
var high_score := 0:
	set(value):
		high_score = value
		hud.high_score = high_score

var asteroid_scene := preload("res://scenes/asteroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives := 3:
	set(value):
		lives = value
		hud.init_lives(value)

func _ready() -> void:
	game_over_screen.hide()
	score = 0
	lives = 3
	minimum_asteroids = 0
	player.laser_shot.connect(_on_player_laser_shot)
	player.died.connect(_on_player_died)
	for asteroid in asteroids.get_children():
		asteroid.exploded.connect(_on_asteroid_exploded)
		pass
	load_scores()
	name_input.show()
	get_tree().paused = true


func _process(_delta: float) -> void: 
	#if Input.is_action_just_pressed("reset"): # For bugtesting; resets the scene when the button is pressed
		#get_tree().reload_current_scene()
	if asteroids.get_children().size()<=minimum_asteroids:
		spawn_new_asteroids()
	pass


func spawn_new_asteroids() -> void:
	if not asteroid_spawn_area.has_overlapping_bodies():
		minimum_asteroids+=1
		var screen_size := get_viewport_rect().size
		spawn_asteroid(Vector2(0,0), Asteroid.AsteroidSize.LARGE)
		spawn_asteroid(Vector2(screen_size.x,0), Asteroid.AsteroidSize.LARGE)
		spawn_asteroid(Vector2(0,screen_size.y), Asteroid.AsteroidSize.LARGE)
		spawn_asteroid(Vector2(screen_size.x,screen_size.y), Asteroid.AsteroidSize.LARGE)
	pass

func _on_player_laser_shot(laser:Laser) -> void:
	lasers.add_child(laser)

func _on_player_died() -> void:
	lives -= 1
	player.global_position = player_spawn_pos.global_position
	if lives<=0:
		#get_tree().reload_current_scene()
		await get_tree().create_timer(1).timeout
		game_over_screen.show()
		save_score(score)
		#show_scoreboard()
	else:
		await get_tree().create_timer(1).timeout
		while not player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_pos.global_position)
	#print(lives)


func _on_asteroid_exploded(pos:Vector2, size, points:int) -> void:
	score+=points
	for i in 2:
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass
	#print(score)


func spawn_asteroid(pos:Vector2, size) -> void:
	var asteroid_var = asteroid_scene.instantiate()
	asteroid_var.global_position = pos
	asteroid_var.size = size
	asteroid_var.exploded.connect(_on_asteroid_exploded)
	asteroids.call_deferred("add_child",asteroid_var)

func show_scoreboard() -> void:
	score_board.set_score_list(high_score_list)
	score_board.show()
	score_board.get_node("BackButton").disabled = false
	pass


func save_score(_points:=0) -> void:
	if score>high_score:
		high_score_player = player_name
		high_score = score
	#pass
	save_game()
	#config_save()
	
func load_scores() -> void:
	load_game()
	#config_load()
	#high_score = find_high_score()
#
#func find_high_score() -> int:
	#var highest_score := 0
	#for i in high_score_list:
		#if high_score_list[i]>highest_score:
			#highest_score = high_score_list[i]
			#high_score_player = i
	#return highest_score



	



#"""
func save() -> Dictionary:
	#var save_dict := {
		#"high_score" : high_score,
		#"player_name" : "AAA"
	#}
	if high_score_list.get_or_add(player_name,0) <= score:
		high_score_list[player_name] = score
	#high_score_list[player_name] = score
	#high_score_list["C"] = 10
	#high_score_list["D"] = 250
	var save_dict := high_score_list
	#var player_name = "AAA"
	#var score_list := {
		#player_name : score
	#}
	#score_list[player_name] = score
	return save_dict
#"""

#"""
# # Note: This can be called from anywhere inside the tree. This function is
# # path independent.
# # Go through everything in the persist category and ask them to return a
# # dict of relevant variables.
func save_game():
	#print("save_game() entered")
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	#var save_nodes = [self]
	#for node in save_nodes:
		# # # Check the node is an instanced scene so it can be instanced again during load.
		#if node.scene_file_path.is_empty():
			#print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			#continue
#
		# # # Check the node has a save function.
		#if !node.has_method("save"):
			#print("persistent node '%s' is missing a save() function, skipped" % node.name)
			#continue
#
		# # Call the node's save function.
	var node_data = self.call("save")
#
		# # JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(node_data)
#
		# # Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
#"""

#"""
# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	#print("load_game() entered")
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
#
	# # This is all used for loading in a list of nodes
	# # We need to revert the game state so we're not cloning objects
	# # during loading. This will vary wildly depending on the needs of a
	# # project, so take care with this step.
	# # For our example, we will accomplish this by deleting saveable objects.
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	#for i in save_nodes:
		#i.queue_free()
#
	# # Load the file line by line and process that dictionary to restore
	# # the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		 # Creates the helper class to interact with JSON.
		var json = JSON.new()

		 # Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		 # Get the data from the JSON object.
		var node_data = json.data

		 # Firstly, we need to create the object and add it to the tree and set its position.
		#var new_object = load(node_data["filename"]).instantiate()
		#get_node(node_data["parent"]).add_child(new_object)
		#new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		 # Now we set the remaining variables.
		high_score = 0
		for i in node_data.keys():
			#if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				#continue
			#new_object.set(i, node_data[i])
			#print(i,", ",node_data[i])
			#self.set(i,node_data[i])
			high_score_list[i] = node_data[i]
			if high_score_list[i]>high_score:
				high_score_player = i
				high_score = high_score_list[i]
			#print("i set to node_data[i]")
#"""
func _exit_tree() -> void:
	save_score()
