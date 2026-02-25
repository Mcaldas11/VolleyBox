extends RigidBody3D

var touched_ground = false

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if touched_ground:
		return

	# opcional: verificar se é o chão
	if body.name == "Floor" or body.name == "Campo" or body is StaticBody3D:

		touched_ground = true

		# espera 0.5 segundos
		await get_tree().create_timer(0.5).timeout

		queue_free()
