extends Node

var monedas: int = 0

func agregar_monedas(cantidad: int):
	monedas += cantidad

func _ready():
	add_to_group("gestor_monedas")
	monedas = 1000  # temporal para probar

@onready var label_monedas = $"../monedas"

func _process(_delta):
	label_monedas.text = "Monedas: " + str(monedas)
