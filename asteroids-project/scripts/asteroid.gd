class_name Asteroid extends Area2D

var movement_vector:=Vector2(0,-1)
var speed := 50.0
var rotation_speed := 50.0

enum AsteroidSize{LARGE, MEDIUM, SMALL}

@export var size := AsteroidSize.LARGE

@onready var sprite := $Sprite2D
@onready var collision_shape := $CollisionShape2D
@onready var shape := $Polygon2D # Temporary

var points:int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.SMALL:
				return 25
			_:
				return 0

signal exploded(pos, size, points)

func _ready() -> void:
	rotation = randf_range(0, TAU)
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50,100)
			#sprite.texture = preload("res://assets/icon.svg") # Placeholder texture
			collision_shape.set_deferred("shape", preload("res://resources/asteroid_collision_large.tres"))
			shape.scale = Vector2(2,2)
		AsteroidSize.MEDIUM:
			speed = randf_range(100,150)
			#sprite.texture = preload("res://assets/icon.svg")
			collision_shape.set_deferred("shape", preload("res://resources/asteroid_collision_medium.tres"))
			shape.scale = Vector2(1,1)
		AsteroidSize.SMALL:
			speed = randf_range(150,200)
			#sprite.texture = preload("res://assets/icon.svg")
			collision_shape.set_deferred("shape", preload("res://resources/asteroid_collision_small.tres"))
			shape.scale = Vector2(0.5,0.5)
	rotation_speed = speed + randf_range(-25,25)

func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta

	var screen_size := get_viewport_rect().size
	var radius = collision_shape.shape.radius
	if global_position.y+radius < 0:
		global_position.y = screen_size.y+radius
	elif global_position.y-radius > screen_size.y:
		global_position.y = -radius
	if global_position.x+radius < 0:
		global_position.x = screen_size.x+radius
	elif global_position.x-radius > screen_size.x:
		global_position.x = -radius
	
	shape.rotate(deg_to_rad(rotation_speed*delta))

func explode() -> void:
	exploded.emit(global_position, size, points)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	#print("Body entered")
	if body is Player:
		var player = body
		player.die()
		#print("Player died")
