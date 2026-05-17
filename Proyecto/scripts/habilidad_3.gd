extends Area2D

var dano: int = 5
var direccion: int = 1
const VELOCIDAD = 200.0
var impactando: bool = false
var duracion_glitch: float = 3.0
var intervalo_daño: float = 0.5

@onready var raycast = $RayCast2D
@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("volar")
	sprite.flip_h = direccion == -1
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	area_entered.connect(_on_area_entered)
	var jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		raycast.add_exception(jugador)
	raycast.target_position = Vector2(14 * direccion, 0)
	await get_tree().create_timer(0.05).timeout
	raycast.enabled = true

func _process(delta):
	if impactando:
		return
	position.x += VELOCIDAD * direccion * delta
	raycast.target_position = Vector2(14 * direccion, 0)
	if raycast.is_colliding():
		_impactar()

func _on_area_entered(area):
	if impactando:
		return
	if area.name == "Hurtbox":
		_aplicar_glitch(area.get_parent())
		_impactar()

func _impactar():
	impactando = true
	set_process(false)
	sprite.play("impacto")
	await sprite.animation_finished
	queue_free()

func _aplicar_glitch(jefe):
	jefe.aplicar_glitch(dano, duracion_glitch, intervalo_daño)
