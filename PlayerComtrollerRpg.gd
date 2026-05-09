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
	animationTree["parameters/Walking/blend_position"] = moveDirection
	
func _physics_process(_delta):
	validateInput()
	animatePlayer()
	move_and_slide()
	
		
