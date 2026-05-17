extends TextureButton

@export var costo: int = 20
var comprado: bool = false

@onready var raiz_hamburguesa = $"../arbolH/padreH"
@onready var raiz_empanada = $"../arbolE/padreE"
@onready var raiz_pizza = $"../arbolP/padreP"
@onready var animacion = $AnimatedSprite2D

func _ready():
	pressed.connect(_intentar_comprar)
	_actualizar_visual()

func _todos_completos() -> bool:
	return $"../arbolH/h2".comprado and $"../arbolH/h3".comprado and \
		   $"../arbolE/e2".comprado and $"../arbolE/e3".comprado and \
		   $"../arbolP/p2".comprado and $"../arbolP/p3".comprado

func _intentar_comprar():
	if comprado:
		return
	if not _todos_completos():
		print("Debes completar los 3 árboles primero")
		return
	var gestor = get_tree().get_first_node_in_group("gestor_monedas")
	if gestor and gestor.monedas >= costo:
		gestor.monedas -= costo
		comprado = true
		_actualizar_visual()
	else:
		print("No tienes suficientes monedas")

func _actualizar_visual():
	if comprado:
		animacion.visible = true
		animacion.play("bonus")
	else:
		animacion.visible = false
