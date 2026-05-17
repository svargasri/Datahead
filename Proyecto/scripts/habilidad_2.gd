extends Area2D

var dano: int = 25
var direccion: int = 1
const VELOCIDAD_X = 200.0
const VELOCIDAD_Y = -200.0
var velocidad: Vector2
var impactando: bool = false

@onready var raycast = $RayCast2D
@onready var sprite = $AnimatedSprite2D

func _ready():
	velocidad = Vector2(VELOCIDAD_X * direccion, VELOCIDAD_Y)
	sprite.play("volar")
	sprite.flip_h = direccion == -1
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	area_entered.connect(_on_area_entered)
	var jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		raycast.add_exception(jugador)
	await get_tree().create_timer(0.05).timeout
	raycast.enabled = true

func _process(delta):
	if impactando:
		return
	velocidad.y += 600 * delta
	position += velocidad * delta
	raycast.target_position = Vector2(velocidad.x * delta * 2, velocidad.y * delta * 2).normalized() * 14
	if raycast.is_colliding():
		_impactar()

func _on_area_entered(area):
	if impactando:
		return
	if area.name == "Hurtbox":
		area.get_parent().recibir_daño(dano)
		_impactar()

func _impactar():
	impactando = true
	set_process(false)
	sprite.play("impacto")
	await sprite.animation_finished
	queue_free()
