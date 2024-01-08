extends Spatial

var damage

onready var ani = $AnimationPlayer

func _process(delta):
	ani.play("Pulse")


func _on_Timer_timeout():
	queue_free()


func _on_Area_body_entered(body):
	if body.is_in_group("Enemy"):
		yield(get_tree().create_timer(.25), "timeout")
		while true:
			body.health -= damage
			body.takenDamage = true
			yield(get_tree().create_timer(.15), "timeout")
