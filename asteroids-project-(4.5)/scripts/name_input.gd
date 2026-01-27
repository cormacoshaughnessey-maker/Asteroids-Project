extends Control

#signal new_name_submitted
@onready var game_root_node := self.get_parent().get_parent()

func _on_line_edit_text_submitted(new_text: String) -> void:
	#new_name_submitted.emit(new_text)
	game_root_node.player_name = new_text
	get_tree().paused = false
	self.hide()

func display_scoreboard() -> void:
	game_root_node.show_scoreboard()
	self.hide()
	$Button.disabled = true
