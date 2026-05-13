class_name LetterInput extends Control

var letter_list = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"]

var select_index := 0:
	set(value):
		select_index = value
		if select_index >= letter_list.size():
			select_index = 0
		elif select_index < 0:
			select_index = letter_list.size()-1
		letter_display.text = letter_list[select_index]


@onready var letter_display := $LetterDisplay


func select_up() -> void:
	select_index += 1


func select_down() -> void:
	select_index -= 1


func confirm_selection() -> String:
	return letter_list[select_index]


func _ready() -> void:
	select_index = 0
