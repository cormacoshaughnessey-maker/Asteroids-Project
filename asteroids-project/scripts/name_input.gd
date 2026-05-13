extends Control

#signal new_name_submitted
@onready var game_root_node := self.get_parent().get_parent()
@onready var letter_inputs := $LetterInputs
@onready var letter_select_indicator := $LetterSelectIndicator
var letter_input_index := 0
var selecting_name := false

func _on_line_edit_text_submitted(new_text: String) -> void:
	#new_name_submitted.emit(new_text)
	game_root_node.player_name = new_text
	get_tree().paused = false
	self.hide()


func display_scoreboard() -> void:
	game_root_node.show_scoreboard()
	self.hide()
	$Button.disabled = true


func _physics_process(delta: float) -> void:
	if selecting_name:
		letter_select_indicator.global_position = letter_inputs.get_child(letter_input_index).global_position
		letter_select_indicator.global_position.x += 25
		letter_select_indicator.global_position.y -= 20
		if Input.is_action_just_pressed("shoot"):
			letter_input_index += 1
			if letter_input_index >= letter_inputs.get_children().size():
				letter_input_confirm(letter_inputs.get_children())
		elif Input.is_action_just_pressed("move_forward"):
			letter_inputs.get_child(letter_input_index).select_up()
		elif Input.is_action_just_pressed("move_backward"):
			letter_inputs.get_child(letter_input_index).select_down()


func letter_input_confirm(letter_inputs:Array[Node]) -> void:
	var new_text := ""
	for i in letter_inputs:
		new_text += i.confirm_selection()
	_on_line_edit_text_submitted(new_text)
	selecting_name = false
