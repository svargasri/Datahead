extends Area2D

const VELOCIDAD = 150.0
var DAÑO : int = 10
const TIEMPO_VIDA = 4.0

@onready var sprite = $AnimatedSprite2D
@onready var explosion = $SpriteExplosion
@onready var timer = $Timer
@onready var collision = $CollisionShape2D
@onready var raycast = $RayCast2D
@onready var audio_explosion = $AudioExplosion

func _ready():
	match GameManager.dificultad_actual:
		1: DAÑO = 5
		2: DAÑO = 10
		3: DAÑO = 15
	explosion.hide()
	sprite.play("VolarA")
	timer.wait_time = TIEMPO_VIDA
	timer.start()
	var jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		raycast.add_exception(jugador)

func _physics_process(delta):
	global_position.y += VELOCIDAD * delta
	if raycast.is_colliding():
		explotar()
		return
	if global_position.y >= 192:
		explotar()
		return
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.recibir_daño(DAÑO)
			explotar()
			return

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.recibir_daño(DAÑO)
		explotar()
	elif body.is_in_group("suelo"):
		explotar()

func _on_timer_timeout():
	explotar()

func explotar():
	set_physics_process(false)
	collision.set_deferred("disabled", true)
	sprite.hide()
	explosion.show()
	audio_explosion.play()
	explosion.play("Explosion")
	await explosion.animation_finished
	queue_free()
