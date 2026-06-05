extends CharacterBody2D

@export var max_hp: int = 100
@export var attack_cooldown: float = 2.0
var current_hp: int

@onready var sprite       = $AnimatedSprite2D
@onready var hurtbox      = $Hurtbox
@onready var attack_timer = $AttackTimer
@onready var hp_bar       = $BossHPBar
@onready var shoot_point  = $ShootPoint

@export var rayo_scene   : PackedScene
@export var cohete_scene : PackedScene
@export var bomba_scene  : PackedScene
@export var lluvia_scene : PackedScene

@onready var audio_daño    = $AudioDaño
@onready var audio_muerte  = $AudioMuerte
@onready var audio_disparo = $AudioDisparo

var daño_rayo: float = 2.5

# ── Estructuras de datos ──────────────────────────────────────
var ataques        : Array = []
var priority_queue : Array = []
var cohetes_activos: Array = []

var arbol_decision    : Dictionary = {}
var estado_actual     : String = "normal"
var historial_ataques : Array = []

var glitch_activo : bool = false
var muerto        : bool = false

@export var nivel_key : String = "nivel1"

# ── Parámetros por dificultad ─────────────────────────────────
func _get_params() -> Dictionary:
	match GameManager.dificultad_actual:
		1: return { "cooldown": 2.0, "hp": 500, "daño_rayo": 2.5 }
		2: return { "cooldown": 1.3, "hp": 750, "daño_rayo": 4.0 }
		3: return { "cooldown": 0.8, "hp": 1000, "daño_rayo": 6.0 }
	return { "cooldown": 2.0, "hp": 500, "daño_rayo": 2.5 }

func _ready():
	var params      = _get_params()
	daño_rayo       = params["daño_rayo"]
	max_hp          = params["hp"]
	attack_cooldown = params["cooldown"]
	current_hp      = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value     = max_hp
	motion_mode     = MotionMode.MOTION_MODE_FLOATING

	print("Boss listo — dificultad: ", GameManager.dificultad_actual)
	print("HP: ", max_hp, " Cooldown: ", attack_cooldown)

	_init_ataques()

	match GameManager.dificultad_actual:
		1: _build_priority_queue()
		2: _build_arbol_decision()
		3: _build_priority_queue()

	attack_timer.wait_time = attack_cooldown
	attack_timer.start()
	print("Timer iniciado: ", attack_timer.wait_time)
	sprite.play("Idle")

# ══════════════════════════════════════════════════════════════
#  DIFICULTAD 1 — Cola con prioridad + Pila de cohetes
# ══════════════════════════════════════════════════════════════
func _init_ataques():
	ataques = [
		{ "nombre": "rayo",           "funcion": _ataque_rayo,           "peso": 20 },
		{ "nombre": "cohetes",        "funcion": _ataque_cohetes,        "peso": 20 },
		{ "nombre": "lluvia_cohetes", "funcion": _ataque_lluvia_cohetes, "peso": 20 },
		{ "nombre": "bomba",          "funcion": _ataque_bomba,          "peso": 20 },
	]

func _build_priority_queue():
	priority_queue = ataques.duplicate()
	priority_queue.sort_custom(func(a, b): return a["peso"] > b["peso"])

func _elegir_ataque_cola() -> Dictionary:
	var total = 0
	for a in ataques:
		total += a["peso"]
	var roll = randi() % total
	var acumulado = 0
	for a in priority_queue:
		acumulado += a["peso"]
		if roll < acumulado:
			return a
	return priority_queue[0]

func _push_cohete(cohete): cohetes_activos.append(cohete)
func _pop_cohete():
	if cohetes_activos.is_empty(): return null
	return cohetes_activos.pop_back()
func _explotar_ultimo_cohete():
	var c = _pop_cohete()
	if c and is_instance_valid(c): c.explotar()

# ══════════════════════════════════════════════════════════════
#  DIFICULTAD 2 — Árbol de decisión + Diccionario de estados
# ══════════════════════════════════════════════════════════════
func _build_arbol_decision():
	arbol_decision = {
		"condicion": "hp_bajo",
		"rama_true": {
			"condicion": "historial_rayo",
			"rama_true":  { "ataque": "bomba" },
			"rama_false": { "ataque": "rayo" },
		},
		"rama_false": {
			"condicion": "historial_cohete",
			"rama_true":  { "ataque": "lluvia_cohetes" },
			"rama_false": { "ataque": "cohetes" },
		},
	}
	estado_actual = "normal"
	print("Árbol de decisión construido")

func _evaluar_arbol(nodo: Dictionary) -> String:
	if nodo.has("ataque"):
		return nodo["ataque"]
	var condicion = nodo["condicion"]
	var resultado = _evaluar_condicion(condicion)
	if resultado:
		return _evaluar_arbol(nodo["rama_true"])
	else:
		return _evaluar_arbol(nodo["rama_false"])

func _evaluar_condicion(condicion: String) -> bool:
	match condicion:
		"hp_bajo":          return current_hp < max_hp * 0.5
		"historial_rayo":   return "rayo" in historial_ataques
		"historial_cohete": return "cohetes" in historial_ataques
	return false

func _elegir_ataque_arbol() -> Dictionary:
	var nombre = _evaluar_arbol(arbol_decision)
	historial_ataques.append(nombre)
	if historial_ataques.size() > 3:
		historial_ataques.pop_front()
	print("Ataque por árbol: ", nombre, " | Historial: ", historial_ataques)
	for a in ataques:
		if a["nombre"] == nombre:
			return a
	return ataques[0]

# ══════════════════════════════════════════════════════════════
#  TIMER
# ══════════════════════════════════════════════════════════════
func _on_attack_timer_timeout():
	print("Timer disparado — eligiendo ataque")
	var ataque : Dictionary
	match GameManager.dificultad_actual:
		1: ataque = _elegir_ataque_cola()
		2: ataque = _elegir_ataque_arbol()
		3: ataque = _elegir_ataque_cola()
		_: ataque = _elegir_ataque_cola()
	print("Ataque elegido: ", ataque.get("nombre", "ninguno"))
	ataque["funcion"].call()

# ══════════════════════════════════════════════════════════════
#  ATAQUES
# ══════════════════════════════════════════════════════════════
func _ataque_rayo():
	print("Spawneando rayo — shoot_point: ", shoot_point.global_position)
	if not rayo_scene:
		print("ERROR: rayo_scene no asignado")
		return
	var rayo = rayo_scene.instantiate()
	rayo.global_position = shoot_point.global_position
	get_parent().add_child(rayo)
	print("Rayo agregado al padre: ", get_parent().name)

func _ataque_cohetes():
	audio_disparo.play()
	if not cohete_scene: return
	var angulos = [-15.0, -5.0, 5.0, 15.0]
	for angulo in angulos:
		var cohete = cohete_scene.instantiate()
		cohete.global_position = shoot_point.global_position
		get_parent().add_child(cohete)
		cohete.set_direccion(deg_to_rad(angulo))
		_push_cohete(cohete)
	print("Cohetes lanzados")

func _ataque_lluvia_cohetes():
	audio_disparo.play()
	if not lluvia_scene: return
	var jugador = get_tree().get_first_node_in_group("player")
	var base_x = 160.0
	if jugador: base_x = jugador.global_position.x
	for i in range(3):
		var offset = (i - 1.0) * 10
		_spawn_cohete_lluvia_con_delay(base_x, offset)
	print("Lluvia de cohetes iniciada")

func _spawn_cohete_lluvia_con_delay(base_x: float, offset: float):
	await get_tree().create_timer(randf_range(0.1, 0.6)).timeout
	var cohete = lluvia_scene.instantiate()
	cohete.global_position = Vector2(base_x + offset, 0)
	get_parent().add_child(cohete)

func _ataque_bomba():
	audio_disparo.play()
	print("Spawneando bomba — shoot_point: ", shoot_point.global_position)
	if not bomba_scene:
		print("ERROR: bomba_scene no asignado")
		return
	var bomba = bomba_scene.instantiate()
	bomba.position = shoot_point.global_position
	get_parent().add_child(bomba)
	print("Bomba agregada al padre: ", get_parent().name)

# ══════════════════════════════════════════════════════════════
#  DAÑO Y MUERTE
# ══════════════════════════════════════════════════════════════
func recibir_daño(cantidad: int):
	if muerto: return
	current_hp -= cantidad
	hp_bar.value = current_hp
	audio_daño.play()
	sprite.play("Hit")
	await sprite.animation_finished
	sprite.play("Idle")
	if current_hp <= max_hp / 2:
		_explotar_ultimo_cohete()
	if current_hp <= 0:
		morir()

func morir():
	muerto = true
	hurtbox.set_deferred("monitoring", false)
	attack_timer.stop()
	audio_muerte.play()
	sprite.play("Death")
	await sprite.animation_finished
	GameManager.desbloquear_siguiente(nivel_key)
	get_tree().change_scene_to_file("res://Proyecto/scenes/mapa_selector.tscn")

func aplicar_glitch(dano_tick: int, duracion: float, intervalo: float):
	if glitch_activo: return
	glitch_activo = true
	$GlitchCabeza.visible   = true
	$GlitchBrazoIzq.visible = true
	$GlitchBrazoDer.visible = true
	$GlitchPiernas.visible  = true
	$GlitchCabeza.play("glitch")
	$GlitchBrazoIzq.play("glitch")
	$GlitchBrazoDer.play("glitch")
	$GlitchPiernas.play("glitch")
	var tiempo = 0.0
	while tiempo < duracion and is_instance_valid(self):
		recibir_daño(dano_tick)
		await get_tree().create_timer(intervalo).timeout
		tiempo += intervalo
	$GlitchCabeza.visible   = false
	$GlitchBrazoIzq.visible = false
	$GlitchBrazoDer.visible = false
	$GlitchPiernas.visible  = false
	glitch_activo = false
