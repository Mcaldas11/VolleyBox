extends CharacterBody3D

@export var speed = 6.0
@export var run_speed = 10.0

# Salto normal
@export var jump_velocity = 4.5

# Salto ao correr (DIMINUIDO para ficar equilibrado)
@export var run_jump_velocity = 5.5

@export var mouse_sensitivity = 0.002

@export var ball_scene: PackedScene

# força
@export var spike_force = 14.0
@export var bump_force = 8.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_x_rotation = 0.0

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var hitbox = $HitBox

var current_ball = null


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):

	# ========================
	# MOVIMENTO DO RATO
	# ========================
	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * mouse_sensitivity)

		camera_x_rotation -= event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation, -1.2, 1.2)

		camera_pivot.rotation.x = camera_x_rotation


	# ========================
	# SPAWN DA BOLA (G)
	# ========================
	if event.is_action_pressed("spawn_ball"):

		if current_ball == null:

			current_ball = ball_scene.instantiate()

			get_tree().current_scene.add_child(current_ball)

			current_ball.global_position = global_position + Vector3(0,4,0)

			current_ball.tree_exited.connect(_on_ball_deleted)


	# ========================
	# ATAQUE / MANCHE TE
	# BOTÃO ESQUERDO
	# ========================
	if event.is_action_pressed("hit_ball"):

		if current_ball != null and ball_is_in_hitbox():

			var direction = -camera.global_transform.basis.z

			# SPIKE (APENAS NO AR)
			if not is_on_floor():

				current_ball.apply_central_impulse(
					direction * spike_force + Vector3(0, 2.5, 0)
				)

				print("SPIKE")

			# MANCHE TE (APENAS NO CHÃO)
			else:

				current_ball.apply_central_impulse(
					direction * bump_force + Vector3(0, 4.0, 0)
				)

				print("MANCHE TE")


func ball_is_in_hitbox():

	var bodies = hitbox.get_overlapping_bodies()

	for body in bodies:

		if body == current_ball:
			return true

	return false


func _physics_process(delta):

	# ========================
	# DETETAR SE ESTÁ A CORRER (SHIFT)
	# ========================
	var is_running = Input.is_action_pressed("run")


	# ========================
	# GRAVIDADE
	# ========================
	if not is_on_floor():
		velocity.y -= gravity * delta


	# ========================
	# SALTO
	# ========================
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():

		if is_running:

			# salto ao correr (equilibrado)
			velocity.y = run_jump_velocity

			# pequeno impulso para frente
			velocity += -camera.global_transform.basis.z * 1.5

		else:

			velocity.y = jump_velocity


	# ========================
	# MOVIMENTO
	# ========================
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var current_speed = speed

	if is_running:
		current_speed = run_speed


	if direction:

		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	else:

		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)


	move_and_slide()


func _on_ball_deleted():

	current_ball = null
