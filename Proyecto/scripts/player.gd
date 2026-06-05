extends CharacterBody2D

# 1. CONSTANTES Y REFERENCIAS
const SPEED = 100.0
const JUMP_VELOCITY = -300.0
@onready var sprite = $AnimatedSprite2D
@onready var hp_bar = $"/root/Nivel1/vidajugador/PlayerHPBar"
@onready var corazon1 = $"/root/Nivel1/vidajugador/Corazon1"
@onready var corazon2 = $"/root/Nivel1/vidajugador/Corazon2"
@onready var corazon3 = $"/root/Nivel1/vidajugador/Corazon3"
@onready var icono_h2 = $"/root/Nivel1/vidajugador/IconoH2"
@onready var icono_h3 = $"/root/Nivel1/vidajugador/IconoH3"
@onready var audio_disparo = $AudioDisparo
@onready var audio_daño = $AudioDaño
@onready var audio_salto = $AudioSalto
@onready var audio_muerte = $AudioMuerte
@onready var audio_cooldown = $AudioCooldown

# 2. HABILIDADES
var dano_h1: int = 5
var dano_h2: int = 10
var dano_h3: int = 15
var vida: int = 100
var max_vida: int = 100
var vidas: int = 3
var recibiendo_daño: bool = false
var muerto: bool = false
var cooldown_h1: float = 0.3
var cooldown_h2: float = 5
var cooldown_h3: float = 10
var puede_h1: bool = true
var puede_h2: bool = true
var puede_h3: bool = true
@export var proyectil_h1: PackedScene
@export var proyectil_h2: PackedScene
@export var proyectil_h3: PackedScene

# 3. ESTADOS
enum State { IDLE, RUN, JUMP }
var current_state = State.IDLE
var apunta_derecha = true

func _ready():
	hp_bar.max_value = max_vida
	hp_bar.value = vida
	corazon1.play("girar")
	corazon2.play("girar")
	corazon3.play("girar")
	icono_h2.play("activo")
	icono_h3.play("activo")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	var direction = Input.get_axis("move_left", "move_right")
	if not is_on_floor():
		current_state = State.JUMP
	elif direction != 0:
		current_state = State.RUN
	else:
		current_state = State.IDLE
	_update_animations(direction)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		audio_salto.play()
	if Input.is_action_just_pressed("habilidad_1") and puede_h1:
		_usar_h1()
	if Input.is_action_just_pressed("habilidad_2") and puede_h2:
		_usar_h2()
	if Input.is_action_just_pressed("habilidad_3") and puede_h3:
		_usar_h3()
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _usar_h1() -> void:
	puede_h1 = false
	audio_disparo.play()
	sprite.play("disparar")
	var p = proyectil_h1.instantiate()
	p.dano = dano_h1
	p.global_position = $Muzzle.global_position + Vector2(20 * (1 if apunta_derecha else -1), 0)
	p.direccion = 1 if apunta_derecha else -1
	get_tree().current_scene.add_child(p)
	await get_tree().create_timer(cooldown_h1).timeout
	puede_h1 = true

func _usar_h2() -> void:
	puede_h2 = false
	audio_disparo.play()
	icono_h2.play("cooldown")
	sprite.play("disparar")
	var p = proyectil_h2.instantiate()
	p.dano = dano_h2
	p.global_position = $Muzzle.global_position
	p.direccion = 1 if apunta_derecha else -1
	get_tree().current_scene.add_child(p)
	await get_tree().create_timer(cooldown_h2).timeout
	puede_h2 = true
	icono_h2.play("activo")
	audio_cooldown.play()

func _usar_h3() -> void:
	puede_h3 = false
	audio_disparo.play()
	icono_h3.play("cooldown")
	sprite.play("disparar")
	var p = proyectil_h3.instantiate()
	p.dano = dano_h3
	p.global_position = $Muzzle.global_position
	p.direccion = 1 if apunta_derecha else -1
	get_tree().current_scene.add_child(p)
	await get_tree().create_timer(cooldown_h3).timeout
	puede_h3 = true
	icono_h3.play("activo")
	audio_cooldown.play()

func _update_animations(dir):
	if muerto:
		return
	if dir > 0:
		sprite.flip_h = false
		apunta_derecha = true
	elif dir < 0:
		sprite.flip_h = true
		apunta_derecha = false
	if recibiendo_daño:
		return
	var anim_to_play = ""
	match current_state:
		State.IDLE: anim_to_play = "idle"
		State.RUN:  anim_to_play = "run"
		State.JUMP: anim_to_play = "jump"
	if sprite.animation != anim_to_play:
		sprite.play(anim_to_play)

func recibir_daño(cantidad: int):
	if muerto:
		return
	vida -= cantidad
	hp_bar.value = vida
	if vida <= 0:
		_morir()
	else:
		_animar_daño()

func _animar_daño():
	recibiendo_daño = true
	audio_daño.play()
	sprite.play("daño")
	await get_tree().create_timer(0.3).timeout
	recibiendo_daño = false

func _morir():
	muerto = true
	puede_h1 = false
	puede_h2 = false
	puede_h3 = false
	audio_muerte.play()
	sprite.play("muerte")
	await sprite.animation_finished
	vidas -= 1
	_actualizar_corazones()
	if vidas <= 0:
		queue_free()
	else:
		_respawnear()

func _respawnear():
	vida = max_vida
	hp_bar.value = vida
	muerto = false
	puede_h1 = true
	puede_h2 = true
	puede_h3 = true
	sprite.play("idle")

func _actualizar_corazones():
	corazon1.visible = vidas >= 1
	corazon2.visible = vidas >= 2
	corazon3.visible = vidas >= 3
