extends CharacterBody3D

var defaultHealth = 150
var health = 150
var hidden = false
var takenDamage = false

@onready var respawnTimer = $RespawnTimer
@onready var bodyCollider = $BodyCollider
@onready var headCollider = $HeadCollider
@onready var damageTaken = $DamageTaken

func _ready():
	pass

func _process(delta):
	if takenDamage == true:
		damageTaken.play("DamgeTaken")
		takenDamage = false
	if health <= 0 and !hidden:
		hide()
		respawnTimer.start()
		bodyCollider.set_disabled(true)
		headCollider.set_disabled(true)
		hidden = true


func _on_RespawnTimer_timeout():
	show()
	bodyCollider.set_disabled(false)
	headCollider.set_disabled(false)
	hidden = false
	health = defaultHealth
