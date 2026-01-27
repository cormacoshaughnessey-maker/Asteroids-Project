extends Control

var ui_life_scene = preload("res://scenes/ui_life.tscn")

@onready var game_root_node := self.get_parent().get_parent()
@onready var score = $Score:
	set(value): # When trying to set score (variable reference to the score labe node) to something,
		score.text = "SCORE: "+str(value) # 								instead change the text
@onready var lives = $Lives

@onready var high_score = $HighScore:
	set(value):
		high_score.text = "HIGH SCORE ("+game_root_node.high_score_player+"): "+str(value)

func init_lives(amount:int) -> void:
	#for ul in lives.get_children():
		#ul.queue_free()
	#for i in amount:
		#var ul := ui_life_scene.instantiate()
		#lives.add_child(ul)
	var current_lives := lives.get_children().size()
	var amount_to_change = amount - current_lives
	if amount_to_change == 0:
		return
	elif amount_to_change>0:
		for i in amount_to_change:
			var ul := ui_life_scene.instantiate()
			lives.add_child(ul)
	else:
		for i in -amount_to_change:
			lives.get_children()[-1].queue_free()
