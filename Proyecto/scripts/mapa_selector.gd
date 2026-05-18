extends Node2D

@onready var personaje      = $Personaje
@onready var halo_nivel1    = $Halos/HaloNivel1
@onready var halo_nivel2    = $Halos/HaloNivel2
@onready var halo_mejoras   = $Halos/ChazaMejoras
@onready var label_accion   = $UI/LabelAccion
@onready var menu_nivel     = $UI/MenuNivel
@onready var imagen_jefe    = $UI/MenuNivel/TextureRect
@onready var label_historia = $UI/MenuNivel/LabelHistoria
@onready var arbol_habilidades = $ArbolHabilidades

var halo_activo  = null
var menu_abierto = false

func _ready():
	label_accion.visible = false
	menu_nivel.visible   = false
	halo_nivel1.personaje_entro.connect(_al_entrar_halo)
	halo_nivel1.personaje_salio.connect(_al_salir_halo)
	halo_nivel2.personaje_entro.connect(_al_entrar_halo)
	halo_nivel2.personaje_salio.connect(_al_salir_halo)
	halo_mejoras.personaje_entro.connect(_al_entrar_halo)
	halo_mejoras.personaje_salio.connect(_al_salir_halo)

func _al_entrar_halo(halo):
	halo_activo = halo
	label_accion.text    = "Presiona Enter para: " + halo.texto_accion
	label_accion.visible = true

func _al_salir_halo(_halo):
	if not menu_abierto:
		halo_activo          = null
		label_accion.visible = false

func _abrir_menu():
	# Si es la chaza, abre el árbol directo sin menú
	if halo_activo == halo_mejoras:
		arbol_habilidades.abrir()
		label_accion.visible    = false
		menu_abierto            = true
		personaje.puede_moverse = false
		return
	# Para los niveles muestra el menú normal
	imagen_jefe.texture     = halo_activo.imagen_jefe
	label_historia.text     = halo_activo.texto_historia
	menu_nivel.visible      = true
	label_accion.visible    = false
	menu_abierto            = true
	personaje.puede_moverse = false
func _al_presionar_jugar():
	if halo_activo == halo_mejoras:
		menu_nivel.visible      = false
		label_accion.visible    = false
		menu_abierto            = false
		personaje.puede_moverse = true
	else:
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
