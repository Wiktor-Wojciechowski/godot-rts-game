extends Node3D

class_name MovementComponent

@export var speed = 10
@onready var nav_agent = get_node("NavigationAgent3D")

var target_position: Vector3 = Vector3.ZERO
var moving: bool = false

@export var stop_distance = 5.0

func _process(_delta: float) -> void:
	if moving:
		var destination = nav_agent.get_next_path_position()
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		
		get_parent().velocity = direction * speed
		get_parent().move_and_slide()

		if(nav_agent.is_navigation_finished()):
			moving = false

func move_to(new_position: Vector3):
	target_position = new_position
	nav_agent.target_position = target_position + Vector3(0, 1, 0)
	
	var target_pos = Vector3(new_position.x, get_parent().position.y, new_position.z)
	if target_pos != global_position:
		get_parent().look_at(target_pos)
	
	moving = true
	
func stop():
	nav_agent.set_target_position(global_position)
	get_parent().velocity = Vector3.ZERO
	moving = false

func follow_target(target):
	if is_instance_valid(target):
		var distance_to_target = global_position.distance_to(target.global_position)
		
		if target.get("size"):
			if distance_to_target > stop_distance + target.size:
				move_to(target.global_position)
			else:
				stop()
	else:
		stop()
