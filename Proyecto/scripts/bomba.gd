extends Area2D

const VELOCIDAD = 120.0
var DAÑO :int =10
const DURACION_ADVERTENCIA = 1.5

@onready var sprite = $AnimatedSprite2D
@onready var advertencia = $Advertencia
@onready var explosion = $Explosion
@onready var timer = $Timer
@onready var collision = $CollisionShape2D
@onready var area_explosion = $AreaExplosion

var jugador: Node2D = null
var cayendo: bool = true

func _ready():
	match GameManager.dificultad_actual:
		1: DAÑO = 10
		2: DAÑO = 18
		3: DAÑO = 25
	explosion.hide()
	advertencia.hide()
	sprite.play("Bomba")
	jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		global_position.x = jugador.global_position.x
	global_position.y = -20
	advertencia.reparent(get_parent())
	advertencia.global_position = Vector2(global_position.x, 160)
	advertencia.show()
	advertencia.play("Advertencia")

func _on_body_entered(body):
	if body.is_in_group("suelo") or body.is_in_group("player"):
		cayendo = false
		set_physics_process(false)
		advertencia.hide()
		_explotar() 

func _physics_process(delta):
	if cayendo:
		global_position.y += VELOCIDAD * delta


func _advertencia():
	sprite.hide()
	advertencia.show()
	advertencia.play("Advertencia")
	timer.wait_time = randf_range(1.5, 1.8)
	timer.start()
	await timer.timeout
	_explotar()

func _explotar():
	advertencia.hide()
	sprite.hide()
	collision.set_deferred("disabled", true)
	explosion.show()
	explosion.play("ExplosionB")
	for body in area_explosion.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.recibir_daño(DAÑO)
	await explosion.animation_finished
	queue_free()


func _on_timer_timeout() -> void:
	pass
