extends CharacterBody2D

@export var max_hp: int = 100
@export var attack_cooldown: float = 2.0
var current_hp: int

@onready var sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var attack_timer = $AttackTimer
@onready var hp_bar = $BossHPBar
@onready var shoot_point = $ShootPoint

@export var rayo_scene: PackedScene
@export var cohete_scene: PackedScene
@export var bomba_scene: PackedScene
@export var lluvia_scene: PackedScene

var ataques: Array = []
var spawn_positions: Array = []
var spawn_index: int = 0
var priority_queue: Array = []
var cohetes_activos: Array = []

# FUNCIONES
func _ready():
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	motion_mode = MotionMode.MOTION_MODE_FLOATING

	_init_ataques()
	_build_priority_queue()

	attack_timer.wait_time = attack_cooldown
	attack_timer.start()
	sprite.play("Idle")

# ARREGLO DE ATAQUES
func _init_ataques():
	ataques = [
		{ "nombre": "rayo",           "funcion": _ataque_rayo,           "peso": 20 },
		{ "nombre": "cohetes",        "funcion": _ataque_cohetes,        "peso": 20 },
		{ "nombre": "lluvia_cohetes", "funcion": _ataque_lluvia_cohetes, "peso": 20 },
		{ "nombre": "bomba",          "funcion": _ataque_bomba,          "peso": 20 },
	]

# COLA CON PRIORIDAD 
func _build_priority_queue():
	priority_queue = ataques.duplicate()
	priority_queue.sort_custom(func(a, b): return a["peso"] > b["peso"])

func _elegir_ataque() -> Dictionary:
	var total = 0
	for ataque in ataques:
		total += ataque["peso"]

	var roll = randi() % total
	var acumulado = 0
	for ataque in priority_queue:
		acumulado += ataque["peso"]
		if roll < acumulado:
			return ataque

	return priority_queue[0]

# PILA — gestionar cohetes
func _push_cohete(cohete):
	cohetes_activos.append(cohete)

func _pop_cohete():
	if cohetes_activos.is_empty():
		return null
	return cohetes_activos.pop_back()

func _explotar_ultimo_cohete():
	var cohete = _pop_cohete()
	if cohete and is_instance_valid(cohete):
		cohete.explotar()


# TIMER 
func _on_attack_timer_timeout():
	var ataque = _elegir_ataque()
	ataque["funcion"].call()

# IMPLEMENTACION DE ATAQUES
func _ataque_rayo():
	if not rayo_scene:
		return
	var rayo = rayo_scene.instantiate()
	rayo.global_position = shoot_point.global_position
	get_parent().add_child(rayo)

func _ataque_cohetes():
	if not cohete_scene:
		return
	var angulos = [-15.0, -5.0, 5.0, 15.0]
	for angulo in angulos:
		var cohete = cohete_scene.instantiate()
		cohete.global_position = shoot_point.global_position
		get_parent().add_child(cohete)
		cohete.set_direccion(deg_to_rad(angulo))
		_push_cohete(cohete)

func _ataque_lluvia_cohetes():
	if not lluvia_scene:
		return
	var jugador = get_tree().get_first_node_in_group("player")
	var base_x = 160.0
	if jugador:
		base_x = jugador.global_position.x
	var cantidad = 3
	for i in range(cantidad):
		var offset = (i - cantidad / 2.0) * 10
		_spawn_cohete_lluvia_con_delay(base_x, offset)

func _spawn_cohete_lluvia_con_delay(base_x: float, offset: float):
	var delay = randf_range(0.1, 0.6)
	await get_tree().create_timer(delay).timeout
	var cohete = lluvia_scene.instantiate()
	cohete.global_position = Vector2(base_x + offset, 0)
	get_parent().add_child(cohete)

func _ataque_bomba():
	if not bomba_scene:
		return
	var bomba = bomba_scene.instantiate()
	bomba.position = shoot_point.global_position
	get_parent().add_child(bomba)

# DAÑO Y MUERTE
func recibir_daño(cantidad: int):
	current_hp -= cantidad
	hp_bar.value = current_hp
	sprite.play("Hit")
	if current_hp <= max_hp / 2:
		_explotar_ultimo_cohete()
	
	if current_hp <= 0:
		morir()

func morir():
	hurtbox.set_deferred("monitoring", false)
	attack_timer.stop()
	sprite.play("Death")
	await sprite.animation_finished
	queue_free()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	pass
