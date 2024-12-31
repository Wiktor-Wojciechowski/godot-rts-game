extends Node3D

@export var healthcomponent: HealthComponent
@onready var pb = $Sprite3D/SubViewport/ProgressBar

@onready var value = null
@onready var max_value = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthcomponent = get_parent().get_node("HealthComponent")
	value = healthcomponent.health
	max_value = healthcomponent.max_health
	pb.max_value = max_value
	healthcomponent.health_changed.connect(set_value)
	pb.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_value():
	max_value = healthcomponent.max_health
	pb.max_value = max_value
	value = healthcomponent.health
	pb.value = value
	if value == max_value:
		pb.hide()
	else:
		pb.show()
