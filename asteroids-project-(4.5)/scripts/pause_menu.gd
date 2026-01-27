extends Control

@onready var pause_text := $PauseText
@onready var game_node := self.get_parent().get_parent()
@onready var player := game_node.get_node("Player")
#var paused = false

func _ready() -> void:
	pause_text.hide()
	#paused = false
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and player.alive:
		_on_pause_button_pressed()
	pass

func _on_pause_button_pressed():
	if get_tree().paused == false:
		get_tree().paused = true
		self.show()
		pause_text.show()
	else:
		pause_text.hide()
		self.hide()
		get_tree().paused = false
