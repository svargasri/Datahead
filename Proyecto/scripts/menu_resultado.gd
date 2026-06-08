extends CanvasLayer

@onready var pergamino = $Panel/TextureRect
@onready var boton_menu = $Panel/TextureButton

@export var textura_victoria: Texture2D
@export var textura_derrota: Texture2D

func _ready():
	boton_menu.pressed.connect(_al_presionar_menu)
	visible = false

func mostrar_victoria():
	pergamino.texture = textura_victoria
	visible = true
	get_tree().paused = true


func mostrar_derrota():
	pergamino.texture = textura_derrota
	visible = true
	get_tree().paused = true

func _al_presionar_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Proyecto/scenes/mapa_selector.tscn")
