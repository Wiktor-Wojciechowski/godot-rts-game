extends Node3D

@export var enemy: PackedScene
@export var group: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var enemy_instance = enemy.instantiate()
	
	get_tree().current_scene.get_node(group).add_child(enemy_instance)
	enemy_instance.global_position = global_position
