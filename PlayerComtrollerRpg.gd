extends CharacterBody2D

@export var speed = 50
var moveDirection = Vector2.ZERO

@onready var animationTree =$AnimationTree

func _ready():
	animationTree.active = true
	
func validateInput():
		moveDirection = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
		velocity = moveDirection * speed

func animatePlayer():
	if velocity.length() == 0:
		animationTree["parameters/conditions/Idle"]=true
		animationTree["parameters/conditions/Walk"]=false
	else:
		animationTree["parameters/Walking/blend_position"] = moveDirection
		animationTree["parameters/Idle/blend_position"] = moveDirection
		animationTree["parameters/conditions/Idle"]=false
		animationTree["parameters/conditions/Walk"]=true
		
func _physics_process(_delta):
	validateInput()
	animatePlayer()
	move_and_slide()
	
		
