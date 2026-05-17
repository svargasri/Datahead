extends Area2D

var velocidad_bala = 600
var es_especial: bool = false

func set_especial(valor: bool) -> void:
	es_especial = valor
	if es_especial:
		velocidad_bala = 900                     
		$AnimatedSprite2D.scale = Vector2(3, 3)  

func _ready():
	pass
#Cambiar animaciones de la bala (despues de 5 normales pasa a combo)
func _process(delta):
	position.x += velocidad_bala * delta
	$AnimatedSprite2D.play("proj_special" if es_especial else "proj1")
