extends Area2D

var DAÑO: int = 3
const DURACION = 2.0
const VELOCIDAD_BUS = 150.0
var tick_timer: float = 0.0
const INTERVALO_TICK: float = 0.1

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var timer = $Timer
@onready var audio_explosion = $AudioExplosion

var jugador: Node2D = null
var dañando: bool = false

func _ready():
	match GameManager.dificultad_actual:
		1: DAÑO = 3
		2: DAÑO = 6
		3: DAÑO = 10
	jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		global_position = Vector2(400.0, jugador.global_position.y)
	sprite.play("Transmi")
	collision.set_deferred("disabled", false)
	dañando = true
	timer.wait_time = DURACION
	timer.start()

func _on_timer_timeout():
	queue_free()

func _process(delta):
	position.x -= VELOCIDAD_BUS * delta
	if dañando and jugador and is_instance_valid(jugador):
		if overlaps_body(jugador):
			tick_timer += delta
			if tick_timer >= INTERVALO_TICK:
				jugador.recibir_daño(DAÑO)
				tick_timer = 0.0
