extends Control

@onready var score_label := $ScoreLabel
@onready var game_root_node := self.get_parent().get_parent()
@onready var name_input = game_root_node.get_node("UI/NameInput")

func set_score_list(list:Dictionary) -> void:
	var new_text:String
	var score_list:Array
	new_text = "     TOP SCORES:\n"
	for player in list:
		score_list.append([player, list[player]])
	score_list.sort_custom(sort_ascending)
	score_list.reverse()
	for i in 10:
		new_text+=str(i+1)+". "+str(score_list[i][0])+": "+str(int(score_list[i][1]))+"\n"
	score_label.text = new_text

func sort_ascending(a, b):
	if a[1] < b[1]:
		return true
	return false

func _on_button_pressed() -> void:
	name_input.show()
	self.hide()
	$BackButton.disabled = true
	name_input.get_node("Button").disabled = false
	pass # Replace with function body.
