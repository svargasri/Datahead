extends Area2D

const VELOCIDAD = 120.0
var DAÑO : int = 10
const TIEMPO_VIDA = 3.0

@onready var sprite = $AnimatedSprite2D
@onready var explosion = $SpriteExplosion
@onready var timer = $Timer
@onready var collision = $CollisionShape2D
@onready var raycast = $RayCast2D
@onready var audio_explosion = $AudioExplosion

var jugador: Node2D = null
var direccion: Vector2 = Vector2.ZERO
var angulo_inicial: float = 0.0

var listo: bool = false

func _ready():
	match GameManager.dificultad_actual:
		1: DAÑO = 5
		2: DAÑO = 10
		3: DAÑO = 15
	explosion.hide()
	sprite.play("Volar")
	timer.wait_time = TIEMPO_VIDA
	timer.start()
	jugador = get_tree().get_first_node_in_group("player")
	listo = true

func _physics_process(delta):
	if not listo:
		return
	if jugador and is_instance_valid(jugador):
		direccion = (jugador.global_position - global_position).normalized()
	rotation = direccion.angle()
	global_position += direccion * VELOCIDAD * delta
	for body in get_overlapping_bodies():
		if body.is_in_group("suelo"):
			explotar()
			return

func set_direccion(angulo: float):
	direccion = Vector2.LEFT.rotated(angulo)

# COLISIÓN CON EL JUGADOR 
func _on_body_entered(body):
	if body.is_in_group("player"):
		body.recibir_daño(DAÑO)
		explotar()

func _on_timer_timeout():
	explotar()

# EXPLOSIÓN 
func explotar():
	set_physics_process(false)
	collision.set_deferred("disabled", true)
	sprite.hide()
	explosion.show()
	audio_explosion.play()
	explosion.play("Explosion")
	await explosion.animation_finished
	queue_free()
