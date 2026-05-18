extends CanvasLayer

func _ready():
	visible = false
	boton_salir.mouse_entered.connect(_hover_salir)
	boton_salir.pressed.connect(_cerrar)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = false
	if event.is_action_pressed("abrir_tienda"):
		visible = !visible

func abrir():
	visible = true

@onready var boton_salir = $tienda/BotonSalir

func _hover_salir():
	boton_salir.get_node("AnimatedSprite2D").play("salir")

func _cerrar():
	visible = false
	# Devolver control al personaje
	get_tree().get_first_node_in_group("personaje").puede_moverse = true
