extends CharacterBody3D

# Define nodes
@onready var head = $Head
@onready var camera = $Head/Camera3D

# Define the player variables
const walk_speed = 5
const sprint_speed = 8
const sensitivity = 0.003
var speed

# Define camera head bobbing variables
const bob_frequency = 2
const bob_amplitude = 0.08
var bob_time = 0

func _ready():
	# Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Move the camera according to the mouse movement
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		
		# Make sure you can't bend your head backwards
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _headbob() -> Vector3:
	var position = Vector3.ZERO
	
	# Calculate the bob with a sine wave
	position.y = sin(bob_time * bob_frequency) * bob_amplitude
	position.x = cos(bob_time * bob_frequency / 2) * bob_amplitude
	
	return position

func _physics_process(delta):
	# Get input and handle movement
	var input_direction = Input.get_vector("player_left", "player_right", "player_forward", "player_back")
	var direction = (head.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	# Handle sprinting
	if Input.is_action_pressed("player_sprint"):
		speed = sprint_speed
	else:
		speed = walk_speed
	
	# Calculate movement velocity based on moving direction
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 10)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 10)
	
	# Head bobbing
	bob_time += delta * velocity.length()
	camera.transform.origin = _headbob()
	
	# Move the player
	move_and_slide()
