extends Node

# Dificultad actualmente seleccionada
var dificultad_actual : int = 1

var monedas: int = 0

func agregar_monedas(cantidad: int) -> void:
	monedas += cantidad

# Progreso por nivel: cuál es la máxima dificultad desbloqueada
var progreso : Dictionary = {
	"nivel1": 1,
	"nivel2": 1,
	"nivel3": 1,
}

func desbloquear_siguiente(nivel: String) -> void:
	if progreso.has(nivel):
		progreso[nivel] = min(progreso[nivel] + 1, 3)

func dificultad_disponible(nivel: String, dif: int) -> bool:
	return dif <= progreso.get(nivel, 1)

var habilidades_compradas: Dictionary = {}

func marcar_comprada(id: String) -> void:
	habilidades_compradas[id] = true

func esta_comprada(id: String) -> bool:
	return habilidades_compradas.get(id, false)

func get_bonus_daño_h1() -> int:
	var bonus = 0
	if esta_comprada("padreH"): bonus += 5
	if esta_comprada("h2"):     bonus += 5
	if esta_comprada("h3"):     bonus += 5
	return bonus

func get_bonus_daño_h2() -> int:
	var bonus = 0
	if esta_comprada("padreP"): bonus += 5
	if esta_comprada("p2"):     bonus += 5
	if esta_comprada("p3"):     bonus += 5
	return bonus

func get_bonus_daño_h3() -> int:
	var bonus = 0
	if esta_comprada("padreE"): bonus += 1
	if esta_comprada("e2"):     bonus += 1
	if esta_comprada("e3"):     bonus += 1
	return bonus

var bonus_quiz_h1: int = 0
var bonus_quiz_h2: int = 0
var bonus_quiz_h3: int = 0

func _process(_delta):
	if Input.is_action_just_pressed("opciones"):
		get_tree().change_scene_to_file("res://Proyecto/scenes/Opciones.tscn")
