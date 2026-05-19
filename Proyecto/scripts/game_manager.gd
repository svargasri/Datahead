extends Node

# Dificultad actualmente seleccionada
var dificultad_actual : int = 1

# Progreso por nivel: cuál es la máxima dificultad desbloqueada
var progreso : Dictionary = {
	"nivel1": 1,
	"nivel2": 1,
}

func desbloquear_siguiente(nivel: String) -> void:
	if progreso.has(nivel):
		progreso[nivel] = min(progreso[nivel] + 1, 3)

func dificultad_disponible(nivel: String, dif: int) -> bool:
	return dif <= progreso.get(nivel, 1)
