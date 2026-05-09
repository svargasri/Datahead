extends CharacterBody2D

# 1. CONSTANTES Y REFERENCIAS
const SPEED = 500.0
const JUMP_VELOCITY = -600.0
@onready var sprite = $AnimatedSprite2D
@onready var combo_label = $ComboLabel
const bala = preload("res://Proyecto/scenes/projectile.tscn")

# 2. DEFINICIÓN DE ESTADOS
enum State { IDLE, RUN, JUMP, SHOOT_IDLE, SHOOT_RUN, SHOOT_JUMP }
var current_state = State.IDLE
var apunta_derecha = true
var can_shoot = true

# 3. ESTRUCTURAS DE DATOS
var attack_queue: Array = []  # Cola FIFO — disparos normales
var combo_stack: Array = []   # Pila LIFO — disparos especiales
var shot_counter: int = 0
const COMBO_THRESHOLD = 5    

func _physics_process(delta: float) -> void:
	# A. GRAVEDAD
	if not is_on_floor():
		velocity += get_gravity() * delta

	# B. INPUTS
	var direction = Input.get_axis("move_left", "move_right")
	var is_shooting = Input.is_action_pressed("shoot")
	var want_to_jump = Input.is_action_pressed("jump")
	var shoot_special = Input.is_action_just_pressed("special")

	# C. TRANSICIÓN DE ESTADOS
	if not is_on_floor():
		current_state = State.SHOOT_JUMP if is_shooting else State.JUMP
	elif is_shooting:
		current_state = State.SHOOT_RUN if direction != 0 else State.SHOOT_IDLE
	elif direction != 0:
		current_state = State.RUN
	else:
		current_state = State.IDLE

	# D. ANIMACIONES
	_update_animations(direction)

	# E. ACCIONES
	if want_to_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if is_shooting and can_shoot:
		_encolar_disparo()

	if shoot_special and can_shoot:
		_disparar_especial()

	# F. MOVIMIENTO
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)
	move_and_slide()

#contar combo disparos
func _encolar_disparo() -> void:
	shot_counter += 1
	attack_queue.append("normal")

	if shot_counter % COMBO_THRESHOLD == 0:
		combo_stack.push_back("special")
		_actualizar_label()

	_disparar_normal()

#Disparo idle

func _disparar_normal() -> void:
	if not attack_queue.is_empty():
		attack_queue.pop_front()
		_shoot(false)

#Sacar especial filaa
func _disparar_especial() -> void:
	if not combo_stack.is_empty():
		combo_stack.pop_back()
		_shoot(true)
		_actualizar_label()

#Spawn bala
func _shoot(es_especial: bool) -> void:
	can_shoot = false
	var shoot = bala.instantiate()
	get_tree().current_scene.add_child(shoot)

	if not apunta_derecha:
		shoot.global_position = Vector2(
			$Muzzle.global_position.x * -1 + global_position.x * 2,
			$Muzzle.global_position.y
		)
	else:
		shoot.global_position = $Muzzle.global_position

	if not apunta_derecha:
		shoot.velocidad_bala *= -1

	shoot.set_especial(es_especial)

	await get_tree().create_timer(0.2).timeout
	can_shoot = true

#Imprimir aviso combo
func _actualizar_label() -> void:
	if combo_stack.is_empty():
		combo_label.text = ""
	else:
		combo_label.text = "¡Presiona E! x" + str(combo_stack.size())
		combo_label.modulate = Color(0.0, 0.0, 0.0, 1.0) 

func _update_animations(dir):
	if dir > 0:
		sprite.flip_h = false
		apunta_derecha = true
	elif dir < 0:
		sprite.flip_h = true
		apunta_derecha = false

	var anim_to_play = ""
	match current_state:
		State.IDLE:       anim_to_play = "idle"
		State.RUN:        anim_to_play = "run"
		State.JUMP:       anim_to_play = "jump"
		State.SHOOT_IDLE: anim_to_play = "shoot_idle"
		State.SHOOT_RUN:  anim_to_play = "shoot_run"
		State.SHOOT_JUMP: anim_to_play = "shoot_jump"

	if sprite.animation != anim_to_play:
		sprite.play(anim_to_play)
