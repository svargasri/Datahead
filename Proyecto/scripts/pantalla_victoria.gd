extends CanvasLayer

@onready var imagen_jefe    = $Panel/ImagenJefe
@onready var label_victoria = $Panel/LabelVictoria
@onready var boton_salir    = $Panel/BotonSalir

var ruta_mapa : String = "res://Proyecto/scenes/mapa_selector.tscn"

func _ready():
	boton_salir.pressed.connect(_al_presionar_salir)

func mostrar(imagen: Texture2D, texto: String) -> void:
	imagen_jefe.texture    = imagen
	label_victoria.text    = texto
	visible                = true

func _al_presionar_salir() -> void:
	queue_free()
	get_tree().change_scene_to_file(ruta_mapa)
