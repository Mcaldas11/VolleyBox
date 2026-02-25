extends CharacterBody3D

@export var speed = 6.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002

# NOVO
@export var ball_scene: PackedScene

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_x_rotation = 0.0

@onready var camera_pivot = $CameraPivot
@onready var spawn_point = $SpawnPoint
@onready var camera = $CameraPivot/Camera3D

# NOVO
var current_ball = null


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):

	# MOVER CÂMERA
	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * mouse_sensitivity)

		camera_x_rotation -= event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation, -1.2, 1.2)

		camera_pivot.rotation.x = camera_x_rotation


	# SPAWNAR BOLA COM G
	if event.is_action_pressed("spawn_ball"):

		if current_ball == null:

			current_ball = ball_scene.instantiate()

			get_tree().current_scene.add_child(current_ball)

			current_ball.global_transform.origin = spawn_point.global_transform.origin


	# REMATAR COM BOTÃO ESQUERDO
	if event.is_action_pressed("hit_ball"):

		if current_ball != null:

			var direction = -camera.global_transform.basis.z

			current_ball.apply_central_impulse(direction * 12.0)



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
