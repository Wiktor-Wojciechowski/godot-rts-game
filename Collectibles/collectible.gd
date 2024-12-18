extends Node

class_name  Collectible

var collectible_name = 'Collectible'
var collected_amount = 10

@export var collectible_resource: CollectibleData

var pickup_range
@onready var resource_manager: ResourceManager = get_tree().current_scene.find_child("ResourceManager")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pickup_range = get_node("PickupRange")
	pickup_range.body_entered.connect(on_pickup_range_entered)
	
	collectible_name = collectible_resource.collectible_name
	collected_amount = collectible_resource.collected_amount


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_pickup_range_entered(body):
	print('picked up ' + collectible_name)
	resource_manager.add_resource(collectible_name, collected_amount)
	queue_free()

func on_collected():
	pass
