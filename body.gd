extends CharacterBody3D

var thirdperson = false

var qi = 0

var realm = 0

var subrealm = 0

var subrealmNum = {
	"Mortal" : 1,
	"Body Foundation" : 6,
	"Qi Foundation" : 11
	
}

var realmName = ["Mortal", "Body Foundation", "Qi Foundation"]

var realmCap = 100

var realmCapReached = false

var speed = 5.0

var moving = false

var isMeditating = false

var jumpSpeed = 4.5

var mouseSensitivity = 0.10
var defaultMouseSensitivity = 0.10

@onready var head = $Head
@onready var firstPersonCam = $"Head/First-Person"
@onready var thirdPersonCam = $"Head/Third-Person"
@onready var qiNumLabel = $"Head/First-Person/Cultivation Overlay/Qi Num"
@onready var realmText = $"Head/First-Person/Cultivation Overlay/Realm text"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseSensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouseSensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	
	realmCap = floor(realmCap)
	
	if realmName[realm] == "Mortal":
		realmText.text = realmName[realm]
	
	else:
		realmText.text = realmName[realm] + " " + str(subrealm)
	
	qiNumLabel.text = str(qi) + " / " + str(floor(realmCap))
	
	if Input.is_action_just_pressed("Debug Data"):
		print("Speed: " +    str(speed))
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
		thirdperson = true
		
	elif Input.is_action_just_pressed("Third Person Switch") and thirdperson == true:
		firstPersonCam.current = true
		thirdperson = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpSpeed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("sprint"):
		speed *= 2
	if Input.is_action_just_released("sprint"):
		speed /= 2
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		moving = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		moving = false
		
	if Input.is_action_pressed("Breakthrough") and realmCapReached == true:
		
		realmCap *= 1.5
		qi = 0
		subrealm += 1
		realmCapReached = false

		
		if subrealm == subrealmNum[str(realmName[realm])]:
			realm += 1
			subrealm = 1
			speed *= (realm * 1.5)
			jumpSpeed *= (realm * 1.5)
	
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
	

	move_and_slide()
