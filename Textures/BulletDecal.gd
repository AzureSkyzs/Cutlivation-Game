extends Node3D

@onready var wall = $MeshInstance.get_parent().get_parent()

func _ready():
	pass


func _on_Timer_timeout():
	wall.add_to_group("Wall")
	queue_free()
