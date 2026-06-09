extends Control

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Proyecto/scenes/mapa_selector.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_cargar_pressed() -> void:
	get_tree().change_scene_to_file("res://Proyecto/scenes/mapa_selector.tscn")

func _on_opciones_pressed() -> void:
	get_tree().change_scene_to_file("res://Proyecto/scenes/Opciones.tscn")
