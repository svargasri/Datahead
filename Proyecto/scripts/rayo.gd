extends Area2D

var DAÑO_POR_SEGUNDO : float=20.0
const DURACION_DELGADO = 0.4
const DURACION_MEDIO = 0.1
const DURACION_CASI_GRUESO = 0.1
const DURACION_GRUESO = 0.4

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var timer = $Timer

var jugador: Node2D = null
var dañando: bool = false
var tick_timer: float = 0.0
const INTERVALO_TICK: float = 0.1

func _ready():
	match GameManager.dificultad_actual:
		
		1: DAÑO_POR_SEGUNDO = 10.0
		2: DAÑO_POR_SEGUNDO = 25.0
		3: DAÑO_POR_SEGUNDO = 40.0
		
	collision.set_deferred("disabled", true)
	sprite.scale.x = 15.0
	jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		global_position.y = jugador.global_position.y
	global_position.x = 120.0
	_fase_delgado()

func _fase_delgado():
	sprite.play("Delgado")
	timer.wait_time = DURACION_DELGADO
	timer.start()
	await timer.timeout
	_fase_medio()

func _fase_medio():
	sprite.play("Medio")
	timer.wait_time = DURACION_MEDIO
	timer.start()
	await timer.timeout
	_fase_casi_grueso()

func _fase_casi_grueso():
	sprite.play("CasiGrueso")
	timer.wait_time = DURACION_CASI_GRUESO
	timer.start()
	await timer.timeout
	_fase_grueso()

func _fase_grueso():
	sprite.play("Grueso")
	collision.set_deferred("disabled", false)
	dañando = true
	timer.wait_time = DURACION_GRUESO
	timer.start()
	await timer.timeout
	queue_free()

func _process(delta):
	if dañando and jugador and is_instance_valid(jugador):
		if overlaps_body(jugador):
			tick_timer += delta
			if tick_timer >= INTERVALO_TICK:
				jugador.recibir_daño(int(DAÑO_POR_SEGUNDO * INTERVALO_TICK))
				tick_timer = 0.0
