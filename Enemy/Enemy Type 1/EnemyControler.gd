extends CharacterBody3D

var defaultHealth = 150
var health = 150
var hidden = false
var takenDamage = false

enum State {
	IDLE,
	SUS,
	ALERT
}

@export var current_state: State = State.IDLE

var state = State.IDLE

@onready var bodyCollider = $BodyCollider
@onready var headCollider = $HeadCollider
@onready var damageTakenAni = $DamageTaken
@onready var vision = $Head/Vision
@onready var susTimer = $SuspicionTimer
@onready var stateAni = $States

func _ready():
	pass

func _process(delta):
	match state:
		State.IDLE:
			stateAni.play("IDLE")
		State.SUS:
			stateAni.play("SUS")
		State.ALERT:
			stateAni.play("ALERT")
		
	
	if vision.is_colliding() and state != State.ALERT:
		var target = vision.get_collider(0)
		if target == null: return
		if target.is_in_group("Player"):
			state = State.SUS
			await get_tree().create_timer(3).timeout
			if vision.is_colliding():
				if target.is_in_group("Player"):
					state = State.ALERT
	elif state != State.ALERT:
		state = State.IDLE
		
	if takenDamage == true:
		if not damageTakenAni.is_playing():
			match state:
				State.IDLE:
					damageTakenAni.stop()
					damageTakenAni.play("DamgeTakenIDLE")
				State.SUS:
					damageTakenAni.stop()
					damageTakenAni.play("DamgeTakenSUS")
				State.ALERT:
					damageTakenAni.stop()
					damageTakenAni.play("DamgeTakenALERT")
		takenDamage = false
		
	if health < 150:
		state = State.ALERT
	if health <= 0 and !hidden:
		
		hide()
		bodyCollider.set_disabled(true)
		headCollider.set_disabled(true)
		hidden = true
		vision.set_enabled(false)
		
		await get_tree().create_timer(3).timeout
		
		state = State.IDLE
		show()
		bodyCollider.set_disabled(false)
		headCollider.set_disabled(false)
		hidden = false
		health = defaultHealth
		vision.set_enabled(true)
