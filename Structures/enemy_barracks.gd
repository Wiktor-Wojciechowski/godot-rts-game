extends Building

@export var created_enemy:PackedScene
var enemy_limit = 50
var enemy_groups = []
var enemy_group = []
var group_size = 1
var max_groups = 3

@onready var game_manager
@onready var level_enemies = get_tree().current_scene.find_child("Enemies")
@onready var spawn_rate = $SpawnRate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spawn_rate_timeout() -> void:
	var enemy = created_enemy.instantiate()
	
	level_enemies.add_child(enemy)

	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	enemy.global_position = mob_spawn_location.global_position
	
# Add enemy to the current group
	enemy_group.append(enemy)
	if enemy_group.size() == group_size:
		enemy_groups.append(enemy_group.duplicate())  # Use duplicate() to make a copy
		enemy_group.clear()
		if enemy_groups.size() == max_groups:
			spawn_rate.paused = true
