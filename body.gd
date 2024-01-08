extends CharacterBody3D

var thirdperson = false

var qi = 0

var realm = 0

var subrealm = 0

var subrealmNum = {
	"Mortal" : 1,
	"Body Foundation" : 4,
	"Qi Foundation" : 5,
	"Foundation Establishment" : 2,
	"Core Formation": 4,
	"Soul Awakening": 4,
	"Void Enlightenment": 3
	
}

var realmName = [
	"Mortal",
	"Body Foundation", 
	"Qi Foundation", 
	"Foundation Establishment", 
	"Core Formation",
	"Soul Awakening",
	"Void Enlightenment"
	
]

var realmCap = 100

var realmCapReached = false

var speed = 6.0

var currentSpeed = 0

var sprintSpeed = 12.0

var moving = false

var isMeditating = false

var jumpSpeed = 4.5

var canFly = false

var flying = false

var LERP_VAL = .15

var mouseSensitivity = 0.10
var defaultMouseSensitivity = 0.10

var weapon1Visible = false

var fistDamage = 10

var paused = false

@onready var head = $Head
@onready var firstPersonCam = $"Head/First-Person"
@onready var subFistCam = $"Head/First-Person/SubViewportContainer/"
@onready var fistCam = $"Head/First-Person/SubViewportContainer/SubViewport/Fistcam"
@onready var thirdPersonCam = $"Head/Third-Person"
@onready var qiNumLabel = $"Head/First-Person/Cultivation Overlay/Qi Num"
@onready var realmText = $"Head/First-Person/Cultivation Overlay/Realm text"
@onready var arms = $"Head/First-Person/Arms"
@onready var animplayer = $"Head/First-Person/Arms/AnimationPlayer"
@onready var bodyVis = $Body
@onready var hitbox = $"Head/First-Person/Hitbox"
@onready var aimcast = $arms/Aimcast
@onready var pause_menu = $PauseMenu



@onready var bDecal = preload("res://Textures/BulletDecal.tscn")


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion and not paused:
		rotate_y(deg_to_rad(-event.relative.x * mouseSensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouseSensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _unhandled_input(event):
	
	if Input.is_action_just_pressed("pause"):
		pauseMenu()


func pauseMenu():
	paused = not paused
	
	if paused:
		pause_menu.set_visible(true)
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	else:
		pause_menu.set_visible(false)
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		


func _process(delta):
	fistCam.global_transform = firstPersonCam.global_transform

func punch():
	if Input.is_action_just_pressed("hit") and weapon1Visible:
		if not animplayer.is_playing():
			animplayer.play("RightPunch")
		if animplayer.current_animation == "RightPunch":	
			for body in hitbox.get_overlapping_bodies():
				print()
				if body.is_in_group("Enemy"):
					print("Enemy Hit")
					body.health -= fistDamage
#					body.takenDamage = true
				if body.is_in_group("Wall"):
					var b = bDecal.instantiate()
					aimcast.get_collider().add_child(b)
					b.global_transform.origin = aimcast.get_collision_point()
					b.look_at(aimcast.get_collision_point() + aimcast.get_collision_normal(), Vector3.UP)
					body.remove_from_group("Wall")
				if body.is_in_group("BDecal"):
					print("Test" + body.global_transform.origin)
					


func _physics_process(delta):
	
	punch()
	
	
	realmCap = floor(realmCap)
	
	if realmName[realm] == "Mortal":
		realmText.text = realmName[realm]
	
	else:
		realmText.text = realmName[realm] + " " + str(subrealm)
	
	qiNumLabel.text = str(qi) + " / " + str(floor(realmCap))
	
	if Input.is_action_just_pressed("Debug Data"):
		print("Can Fly: " +    str(canFly))
		print("Speed: " +    str(speed))
		print("Sprint Speed: " +    str(sprintSpeed))
		print("JmpSpeed: " + str(jumpSpeed))
		print("Realm: " +    str(realmName[realm]))
		print("RealmCap: " +    str(realmCap))
		print("Subrealm: " + str(subrealm))
		print(subrealmNum[str(realmName[realm])])
	
	if Input.is_action_just_pressed("Fillcap"):
		qi = realmCap
		realmCapReached = true

	if Input.is_action_just_pressed("Third Person Switch") and thirdperson == false:
		thirdPersonCam.current = true
		bodyVis.set_visible(true)
		subFistCam.set_visible(false)
		thirdperson = true
		
	elif Input.is_action_just_pressed("Third Person Switch") and thirdperson == true:
		firstPersonCam.current = true
		bodyVis.set_visible(false)
		subFistCam.set_visible(true)
		thirdperson = false
	
	if Input.is_action_just_pressed("weaponswitch1"):
		weapon1Visible = not weapon1Visible
	
	
	if weapon1Visible:
		arms.set_visible(true)

	if not weapon1Visible:
		arms.set_visible(false)
	
	# Add the gravity.
	if not is_on_floor() and not flying:
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not flying:
		velocity.y = jumpSpeed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("sprint"):
		currentSpeed = speed
		speed = sprintSpeed
		
	if Input.is_action_just_released("sprint"):
		speed = currentSpeed
		currentSpeed = 0
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * speed, LERP_VAL)
		moving = true
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
		moving = false
		
	if Input.is_action_pressed("Breakthrough") and realmCapReached == true:
		
		realmCap *= 1.5
		qi = 0
		subrealm += 1
		realmCapReached = false

		
		if subrealm == subrealmNum[str(realmName[realm])]:
			realm += 1
			subrealm = 1
			
			if speed < 25:
				speed *= floor(realm * 1.25)
			else:
				speed = 50
			sprintSpeed *= floor(realm * 1.25)
			if jumpSpeed < 25:
				jumpSpeed *= floor(realm * 1.25)
			else:
				jumpSpeed = 25
				canFly = true
	if Input.is_action_pressed("Meditate") and moving == false and realmCapReached == false:
		isMeditating = true
		while true:
			if qi == realmCap:
				realmCapReached = true
				break
			if moving == true or isMeditating == false:
				break
			qi += 1
			await get_tree().create_timer(.1).timeout
			if Input.is_action_pressed("Meditate"):
				isMeditating = false
	
	if Input.is_action_just_pressed("Fly") and canFly:
		flying = not flying
		velocity.y = 0
	if Input.is_action_pressed("jump") and flying:
		velocity.y += jumpSpeed
	if Input.is_action_just_released("jump") and flying:
		velocity.y = 0
	if Input.is_action_pressed("Crouch") and flying:
		velocity.y -= jumpSpeed
	if Input.is_action_just_released("Crouch") and flying:
		velocity.y = 0	

	move_and_slide()


func _on_resume_pressed():
	pauseMenu()
