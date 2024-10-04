extends CharacterBody3D

class_name Unit

@onready var selection = $Selection
@onready var health_bar = $HealthBar
@onready var health_component = $HealthComponent
@onready var attack_component = $AttackComponent
@onready var movement_component = $MovementComponent

var team = 1

var current_target = null

func _ready() -> void:
	pass

func _physics_process(_delta):
	if current_target:
		movement_component.follow_target(current_target)
		
		if not is_instance_valid(current_target):
			current_target = null
