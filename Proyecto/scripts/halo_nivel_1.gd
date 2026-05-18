extends Area2D


@export var escena_destino : String = ""
@export var texto_accion   : String = "Entrar"
@export var nivel_activo   : bool   = true
@export var imagen_jefe    : Texture2D
@export var texto_historia : String = ""

signal personaje_entro(halo)
signal personaje_salio(halo)

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("personaje") and nivel_activo:
		emit_signal("personaje_entro", self)

func _on_body_exited(body):
	if body.is_in_group("personaje"):
		emit_signal("personaje_salio", self)
		
