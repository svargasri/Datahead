extends Area2D

var preguntas = [
	{
		"pregunta": "¿Cúal de las siguientes es una mínima?",
		"opciones": ["A) Piense que este bien para que quede bien", "B) Piense que este mal para que quede bien", "C) Piense que este mal para que salga mal"],
		"correcta": 0
	},
	{
		"pregunta": "¿Cúal de las siguientes es una mínima?",
		"opciones": ["A) Todo problema se puede dividir en problemas más grandes", "B) Todo problema se puede dividir en problemas más pequeños", "C) Todo problema es un problema"],
		"correcta": 1
	},
	{
		"pregunta": "¿Cúal de las siguientes es una mínima?",
		"opciones": ["A) Solo hacemos el primero", "B) Solo hacemos el último", "C) Siempre se hace el primero y se hace el último"],
		"correcta": 2
	},
]

var pregunta_actual: int = 0
var quiz_activo: bool = false
var respuestas_correctas: int = 0

@onready var menu_quiz = $menu_quiz
@onready var label_pregunta = $menu_quiz/Panel/label_pregunta
@onready var boton_a = $menu_quiz/Panel/boton_a
@onready var boton_b = $menu_quiz/Panel/boton_b
@onready var boton_c = $menu_quiz/Panel/boton_c
@onready var label_resultado = $menu_quiz/Panel/label_resultado

func _ready():
	menu_quiz.visible = false
	body_entered.connect(_on_body_entered)
	boton_a.pressed.connect(_responder.bind(0))
	boton_b.pressed.connect(_responder.bind(1))
	boton_c.pressed.connect(_responder.bind(2))

func _on_body_entered(body):
	if body.is_in_group("player") and not quiz_activo and not GameManager.easter_egg_completado:
		quiz_activo = true
		pregunta_actual = 0
		respuestas_correctas = 0
		_mostrar_pregunta()

func _mostrar_pregunta():
	if pregunta_actual >= preguntas.size():
		_terminar_quiz()
		return
	var p = preguntas[pregunta_actual]
	label_pregunta.text = p["pregunta"]
	boton_a.text = p["opciones"][0]
	boton_b.text = p["opciones"][1]
	boton_c.text = p["opciones"][2]
	label_resultado.text = ""
	menu_quiz.visible = true

func _responder(opcion: int):
	var p = preguntas[pregunta_actual]
	if opcion == p["correcta"]:
		label_resultado.text = "¡Correcto!"
		respuestas_correctas += 1
		GameManager.bonus_quiz_h1 += 2
		GameManager.bonus_quiz_h2 += 2
		GameManager.bonus_quiz_h3 += 1
	else:
		label_resultado.text = "Incorrecto"
		GameManager.bonus_quiz_h1 -= 1
		GameManager.bonus_quiz_h2 -= 1
	await get_tree().create_timer(1.0).timeout
	pregunta_actual += 1
	_mostrar_pregunta()

func _terminar_quiz():
	menu_quiz.visible = false
	quiz_activo = false
	GameManager.agregar_monedas(100)
	GameManager.easter_egg_completado = true
	var menu = get_tree().get_first_node_in_group("menu_resultado")
	if menu:
		if respuestas_correctas >= 2:
			menu.mostrar_victoria()
		else:
			menu.mostrar_derrota()
