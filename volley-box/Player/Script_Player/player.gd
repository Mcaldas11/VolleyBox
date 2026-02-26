extends CharacterBody3D

@export var speed = 6.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002
@export var ball_scene: PackedScene

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_x_rotation = 0.0

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var hitbox = $HitBox

var current_ball = null


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):

	# RATO
	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * mouse_sensitivity)

		camera_x_rotation -= event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation, -1.2, 1.2)

		camera_pivot.rotation.x = camera_x_rotation


	# SPAWN BALL
	if event.is_action_pressed("spawn_ball"):

		if current_ball == null:

			current_ball = ball_scene.instantiate()

			get_tree().current_scene.add_child(current_ball)

			current_ball.global_position = global_position + Vector3(0,4,0)

			current_ball.tree_exited.connect(_on_ball_deleted)


	# HIT BALL
	if event.is_action_pressed("hit_ball"):

		if current_ball != null and ball_is_in_hitbox():

			var direction = -camera.global_transform.basis.z

			current_ball.apply_central_impulse(direction * 12.0)

			print("Remate válido")


func ball_is_in_hitbox():

	var bodies = hitbox.get_overlapping_bodies()

	for body in bodies:

		if body == current_ball:
			return true

	return false


func _physics_process(delta):

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	else:

		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _on_ball_deleted():

	current_ball = null
