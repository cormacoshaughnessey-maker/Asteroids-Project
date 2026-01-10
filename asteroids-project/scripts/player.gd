class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var deceleration := 3
@export var rotation_speed := 200.0
@export var fire_rate := 0.2

@onready var muzzle := $Muzzle
@onready var collision_shape := $CollisionShape2D
@onready var ray_cast := $RayCast2D
@onready var crosshair := $Crosshair
@onready var crosshair_laser := $CrosshairLaser
@onready var player_sprite := $AnimatedSprite2D

var laser_scene := preload("res://scenes/laser.tscn")

var shoot_is_on_cooldown := false
var alive := true

#func _ready() -> void:
	#acceleration*=60
	#deceleration*=60


func _process(delta: float) -> void:
	if not alive:
		return
	
	if Input.is_action_pressed("shoot"):
		if not shoot_is_on_cooldown:
			shoot_is_on_cooldown = true
			shoot_laser()
			await get_tree().create_timer(fire_rate).timeout
			shoot_is_on_cooldown = false


func _physics_process(delta: float) -> void:
	if not alive:
		return
	
	var input_vector:= Vector2(0, Input.get_axis("move_forward","move_backward"))
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed*delta))
		player_sprite.play("rotate_right")
		
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed*delta))
		player_sprite.play("rotate_left")

	if not Input.is_action_pressed("rotate_left") and not Input.is_action_pressed("rotate_right"):
		player_sprite.play("default")
	
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration)
	
	move_and_slide()
	
	var screen_size := get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
	
	# Try to do somethin' funky with raycasting
	check_raycast()


func check_raycast() -> void:
	if ray_cast.is_colliding():
		crosshair_laser.global_rotation = deg_to_rad(0)
		var collision_point = ray_cast.get_collision_point()
		crosshair.show()
		crosshair.global_position = collision_point
		var crosshair_laser_position = self.position - collision_point
		crosshair_laser.set_point_position(1,-1*crosshair_laser_position)
		#crosshair_laser.default_color = Vector4(1,0,0,0.5)
		crosshair_laser.set_deferred("gradient",preload("res://resources/hit_crosshair_gradient.tres"))
	else:
		crosshair_laser.global_rotation = self.rotation
		crosshair_laser.set_point_position(1,Vector2(0, -2500))
		#crosshair_laser.default_color = Vector4(1,0,0,0.25)
		crosshair_laser.set_deferred("gradient",preload("res://resources/empty_crosshair_gradient.tres"))
		crosshair.hide()


func shoot_laser() -> void:
	var laser_var = laser_scene.instantiate()
	laser_var.global_position = muzzle.global_position
	laser_var.rotation = self.rotation
	laser_shot.emit(laser_var)


func die() -> void:
	#print("Player REALLY died")
	if alive:
		alive = false
		died.emit()
		hide() # If somehow this doesn't work, just hide the sprite instead
		#process_mode = Node.PROCESS_MODE_DISABLED # According to tutorial, doesn't work
		collision_shape.set_deferred("disabled", true)


func respawn(pos:Vector2) -> void:
	if not alive:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		show() # Same as hiding comment
		#process_mode = Node.PROCESS_MODE_INHERIT
		collision_shape.set_deferred("disabled", false)
		rotation = 0
