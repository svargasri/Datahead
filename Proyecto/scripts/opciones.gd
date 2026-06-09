extends Control


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Proyecto/scenes/menu.tscn")


func _on_mute_pressed() -> void:
	AudioServer.set_bus_mute(0, !AudioServer.is_bus_mute(0))


func _on_cargar_pressed() -> void:
	get_tree().change_scene_to_file("res://Proyecto/scenes/mapa_selector.tscn")
