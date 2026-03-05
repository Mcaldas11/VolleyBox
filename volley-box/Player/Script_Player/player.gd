extends CharacterBody3D

# =====================
# MOVIMENTO
# =====================
@export var speed = 6.0
@export var run_speed = 10.0

@export var jump_velocity = 4.5
@export var run_jump_velocity = 6.0

@export var mouse_sensitivity = 0.002


# =====================
# BOLA
# =====================
@export var ball_scene: PackedScene

# força base
@export var spike_force = 2.0
@export var bump_force = 1.4


# =====================
# POWER SYSTEM
# =====================
var power = 8
var min_power = 1
var max_power = 15


# =====================
# REFERENCIAS
# =====================
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_x_rotation = 0.0

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var hitbox = $HitBox

@onready var power_bar = get_tree().current_scene.get_node("CrossHair/PowerBar")
@onready var power_text = get_tree().current_scene.get_node("CrossHair/PowerText")

var current_ball = null


# =====================
# READY
# =====================
func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	update_power_bar()


# =====================
# INPUT
# =====================
func _input(event):

	# =====================
	# MOUSE LOOK
	# =====================
	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * mouse_sensitivity)

		camera_x_rotation -= event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation, -1.2, 1.2)

		camera_pivot.rotation.x = camera_x_rotation


	# =====================
	# POWER CONTROLS
	# =====================
	if event.is_action_pressed("power_up"):

		power = clamp(power + 1, min_power, max_power)
		update_power_bar()


	if event.is_action_pressed("power_down"):

		power = clamp(power - 1, min_power, max_power)
		update_power_bar()


	if event.is_action_pressed("power_3"):

		power = 3
		update_power_bar()


	if event.is_action_pressed("power_6"):

		power = 6
		update_power_bar()


	if event.is_action_pressed("power_15"):

		power = 15
		update_power_bar()


	# =====================
	# SPAWN BALL
	# =====================
	if event.is_action_pressed("spawn_ball"):

		if current_ball == null:

			current_ball = ball_scene.instantiate()

			get_tree().current_scene.add_child(current_ball)

			current_ball.global_position = global_position + Vector3(0,4,0)

			current_ball.tree_exited.connect(_on_ball_deleted)


	# =====================
	# HIT BALL
	# =====================
	if event.is_action_pressed("hit_ball"):

		if current_ball != null and ball_is_in_hitbox():

			var forward = -camera.global_transform.basis.z
			var power_multiplier = power

			# SPIKE (no ar)
			if not is_on_floor():

				var target = get_crosshair_target()
				var direction = (target - current_ball.global_position).normalized()

				var spike_impulse = direction * spike_force * power

				current_ball.apply_central_impulse(spike_impulse)


			# MANCHE TE (no chão)
			else:

				var target = get_crosshair_target()
				var direction = (target - current_ball.global_position).normalized()

				# Quanto menor o power, mais sobe
				var vertical_factor = float(max_power - power) / max_power

				# controla intensidade da parábola
				var vertical_boost = vertical_factor * 6.0

				var bump_impulse = direction * bump_force * power + Vector3.UP * vertical_boost

				current_ball.apply_central_impulse(bump_impulse)

				print("MANCHE TE  | power:", power)


# =====================
# POWER BAR
# =====================
func update_power_bar():

	if power_bar != null:
		power_bar.value = power

	if power_text != null:
		power_text.text = str(power)


# =====================
# HITBOX CHECK
# =====================
func ball_is_in_hitbox():

	var bodies = hitbox.get_overlapping_bodies()

	for body in bodies:

		if body == current_ball:
			return true

	return false


# =====================
# MOVIMENTO
# =====================
func _physics_process(delta):

	var is_running = Input.is_action_pressed("run")


	# gravidade
	if not is_on_floor():
		velocity.y -= gravity * delta


	# salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():

		if is_running:

			velocity.y = run_jump_velocity
			velocity += -camera.global_transform.basis.z * 1.5

		else:

			velocity.y = jump_velocity


	# movimento
	var input_dir = Input.get_vector("ui_left","ui_right","ui_up","ui_down")

	var direction = (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()

	var current_speed = run_speed if is_running else speed


	if direction:

		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	else:

		velocity.x = move_toward(velocity.x,0,current_speed)
		velocity.z = move_toward(velocity.z,0,current_speed)


	move_and_slide()


# =====================
# BALL DELETED
# =====================
func _on_ball_deleted():

	current_ball = null

func get_crosshair_target():

	var space_state = get_world_3d().direct_space_state
	
	var from = camera.global_transform.origin
	var to = from + (-camera.global_transform.basis.z * 200)

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	if result:
		return result.position
	else:
		return to
		
