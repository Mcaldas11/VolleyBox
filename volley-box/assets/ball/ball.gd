extends RigidBody3D

var touched_ground = false

func _ready():

	# ATIVAR DETECÇÃO DE CONTACTOS
	contact_monitor = true
	max_contacts_reported = 10

	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if touched_ground:
		return

	# garantir que não é o próprio player (opcional)
	if body is StaticBody3D:

		touched_ground = true

		print("Bola tocou no chão")

		await get_tree().create_timer(0.5).timeout

		queue_free()
