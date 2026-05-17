extends TextureButton

func _ready():
	pressed.connect(_pausar)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _pausar():
	get_tree().paused = !get_tree().paused
