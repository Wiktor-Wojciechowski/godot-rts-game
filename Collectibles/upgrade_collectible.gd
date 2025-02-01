extends Collectible

class_name UpgradeCollectible

func on_pickup_range_entered(body):
	print('picked up ' + collectible_name)
	
	body.health_component.max_health *= 3.0
	body.health_component.health = body.health_component.max_health
	body.movement_component.speed *= 0.9	
	body.attack_component.attack_damage *= 2.0
	body.scale *= Vector3(1.5, 1.5, 1.5)

	queue_free()
