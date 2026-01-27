class_name Laser extends Area2D

@export var speed := 1200.0
var movement_vector:=Vector2(0,-1)
var move := false

func _enter_tree() -> void:
	await get_tree().create_timer(0.20).timeout
	move = true
	

func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta
	#slow_shot(delta)
	

func slow_shot(delta: float) -> void:
	if move:
		global_position += movement_vector.rotated(rotation) * speed * delta
	else:
		global_position += movement_vector.rotated(rotation) * speed * delta * 0.1


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Asteroid:
		var asteroid:=area
		asteroid.explode()
		queue_free()
	elif area is LaserDespawnZone:
		queue_free()
