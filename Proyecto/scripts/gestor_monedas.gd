extends Node

func _ready():
	add_to_group("gestor_monedas")

@onready var label_monedas = $"../monedas"

func _process(_delta):
	label_monedas.text = "Monedas: " + str(GameManager.monedas)
