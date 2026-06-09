extends Node2D

@onready var personaje         = $Personaje
@onready var halo_nivel1       = $Halos/HaloNivel1
@onready var halo_nivel2       = $Halos/HaloNivel2
@onready var halo_nivel3       = $Halos/HaloNivel3
@onready var halo_easter_egg = $Halos/HaloEasterEgg
@onready var halo_mejoras      = $Halos/ChazaMejoras
@onready var label_accion      = $UI/LabelAccion
@onready var menu_nivel        = $UI/MenuNivel
@onready var imagen_jefe       = $UI/MenuNivel/TextureRect

@onready var boton_dif1        = $UI/MenuNivel/BotonDif1
@onready var boton_dif2        = $UI/MenuNivel/BotonDif2
@onready var boton_dif3        = $UI/MenuNivel/BotonDif3
@onready var arbol_habilidades = $ArbolHabilidades

# Mapea cada halo a su clave en GameManager
const NIVEL_KEY = {
	"HaloNivel1": "nivel1",
	"HaloNivel2": "nivel2",
	"HaloNivel3": "nivel3",
}

var halo_activo  = null
var menu_abierto = false

func _ready():
	label_accion.visible = false
	menu_nivel.visible   = false
	
	print("Conectando señales...")
	print("halo_nivel1 es: ", halo_nivel1)
	
	halo_nivel1.personaje_entro.connect(_al_entrar_halo)
	halo_nivel1.personaje_salio.connect(_al_salir_halo)
	halo_nivel2.personaje_entro.connect(_al_entrar_halo)
	halo_nivel2.personaje_salio.connect(_al_salir_halo)
	halo_nivel3.personaje_entro.connect(_al_entrar_halo)
	halo_nivel3.personaje_salio.connect(_al_salir_halo)
	halo_easter_egg.personaje_entro.connect(_al_entrar_halo)
	halo_easter_egg.personaje_salio.connect(_al_salir_halo)
	halo_mejoras.personaje_entro.connect(_al_entrar_halo)
	halo_mejoras.personaje_salio.connect(_al_salir_halo)
	
	print("Señales conectadas OK")
	
	boton_dif1.pressed.connect(_seleccionar_dif.bind(1))
	boton_dif2.pressed.connect(_seleccionar_dif.bind(2))
	boton_dif3.pressed.connect(_seleccionar_dif.bind(3))

func _al_entrar_halo(halo):
	print("SEÑAL RECIBIDA EN MAPA:  ", halo.name)
	halo_activo          = halo
	label_accion.text    = "Presiona Enter para: " + halo.texto_accion
	label_accion.visible = true

func _al_salir_halo(_halo):
	if not menu_abierto:
		halo_activo          = null
		label_accion.visible = false

func _abrir_menu():
	if halo_activo == halo_mejoras:
		arbol_habilidades.abrir()
		label_accion.visible    = false
		menu_abierto            = true
		personaje.puede_moverse = false
		return
	if halo_activo == halo_easter_egg:
		if GameManager.easter_egg_completado:
			label_accion.text = "Ya completaste el easter egg"
			return
		get_tree().change_scene_to_file("res://Proyecto/scenes/nivelEasterEgg.tscn")
		return
	imagen_jefe.texture     = halo_activo.imagen_jefe
	$UI/MenuNivel/TextureRect2.texture = halo_activo.imagen_menu
	menu_nivel.visible      = true
	label_accion.visible    = false
	menu_abierto            = true
	personaje.puede_moverse = false
	GameManager.dificultad_actual = 1
	_actualizar_botones_dificultad()

func _actualizar_botones_dificultad():
	var nivel_key = NIVEL_KEY.get(halo_activo.name, "nivel1")
	var botones = [boton_dif1, boton_dif2, boton_dif3]

	for i in range(3):
		var dif = i + 1
		var disponible = GameManager.dificultad_disponible(nivel_key, dif)
		var seleccionado = GameManager.dificultad_actual == dif

		botones[i].disabled = not disponible

		if not disponible:
			# Bloqueado — naranja oscuro
			botones[i].modulate = Color(0.5, 0.25, 0.0, 1.0)
		elif seleccionado:
			# Seleccionado — amarillo brillante
			botones[i].modulate = Color(1.0, 1.0, 0.0, 1.0)
		else:
			# Disponible pero no seleccionado — amarillo suave
			botones[i].modulate = Color(1.0, 0.85, 0.3, 1.0)

func _seleccionar_dif(dif: int):
	var nivel_key = NIVEL_KEY.get(halo_activo.name, "nivel1")
	if GameManager.dificultad_disponible(nivel_key, dif):
		GameManager.dificultad_actual = dif
		_actualizar_botones_dificultad()

func _al_presionar_jugar():
	print("Dificultad: ", GameManager.dificultad_actual)
	print("Halo activo: ", halo_activo)
	print("Escena: ", halo_activo.escena_destino)
	get_tree().change_scene_to_file(halo_activo.escena_destino)

func _al_presionar_cerrar():
	menu_nivel.visible      = false
	label_accion.visible    = false
	menu_abierto            = false
	personaje.puede_moverse = true

func _process(_delta):
	if halo_activo != null and not menu_abierto:
		if Input.is_action_just_pressed("ui_accept"):
			_abrir_menu()
