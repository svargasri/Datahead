extends TextureButton

@export var costo: int = 10
@export var nodo_padre: NodePath
@export var efecto: String = ""

var comprado: bool = false

@onready var padre = get_node_or_null(nodo_padre)

func _ready():
	pressed.connect(_intentar_comprar)
	_actualizar_visual()

func esta_disponible() -> bool:
	if nodo_padre == NodePath(""):
		return true
	if padre and padre.comprado:
		return true
	return false

func _intentar_comprar():
	if comprado:
		return
	if not esta_disponible():
		print("Debes comprar el nodo anterior primero")
		return
	var gestor = get_tree().get_first_node_in_group("gestor_monedas")
	if gestor and gestor.monedas >= costo:
		gestor.monedas -= costo
		comprado = true
		_actualizar_visual()
		_aplicar_efecto()
	else:
		print("No tienes suficientes monedas")

func _actualizar_visual():
	if comprado:
		play_animation("comprado")
	elif esta_disponible():
		play_animation("disponible")
	else:
		play_animation("bloqueado")

@onready var animacion = $AnimatedSprite2D

func play_animation(estado: String):
	match estado:
		"comprado":
			animacion.visible = true
			animacion.play("compra")
			modulate = Color(1, 1, 1, 1)
		"disponible":
			animacion.visible = false
			modulate = Color(1, 1, 1, 1)
		"bloqueado":
			animacion.visible = false
			modulate = Color(0.5, 0.5, 0.5, 1)

func _aplicar_efecto():
	var jugador = get_tree().get_first_node_in_group("player")
	if not jugador:
		return
	match efecto:
		"daño_h1": jugador.dano_h1 += 5
		"daño_h2": jugador.dano_h2 += 5
		"daño_h3": jugador.dano_h3 += 5
		"bonus": jugador.bonus_activo = true
