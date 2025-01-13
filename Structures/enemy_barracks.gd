extends Building

@export var created_enemy: PackedScene
@export var spawn_interval: int

var enemy_limit = 50
@export var group_size = 5
var spawn_radius: float = 6.0  # The radius at which enemies will spawn

@onready var game_manager = get_tree().current_scene.get_node("GameManager")
@onready var level_enemies = get_tree().current_scene.find_child("Enemies")
var spawn_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer = $SpawnTimer
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_spawn_timer_timeout() -> void:
	if game_manager.number_of_enemies < 80:
		spawn_enemies(created_enemy)

func spawn_enemies(enemies):
	for i in range(group_size):
		spawn_enemy(enemies)

func spawn_enemy(enemy_type):
	var enemies_node = get_tree().current_scene.find_child("Enemies")
	var enemy = enemy_type.instantiate()
	enemy.seeks_out_buildings = true
	enemy.position = Vector3(0,-10000, 0)
	enemies_node.add_child(enemy)
	
	# Generate random angle between 0 and 360 degrees (converted to radians)
	var random_angle = randf_range(0, 2 * PI)
	
	var random_x = cos(random_angle) * spawn_radius
	var random_z = sin(random_angle) * spawn_radius
	
	var spawn_position = position + Vector3(random_x, 0, random_z)

	enemy.position = spawn_position
