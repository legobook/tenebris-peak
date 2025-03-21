extends CharacterBody3D

# Define nodes
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D

# Define the player variables
const forward_speed = 7
const back_speed = 3
const sensitivity = 0.003
var speed

# Define camera head bobbing variables
const bob_frequency = 3.0
const bob_amplitude = 0.02
var bob_time = 0

func _ready():
	# Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Move the camera according to the mouse movement
		camera_pivot.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		
		# Make sure you can't bend your head backwards
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _headbob() -> Vector3:
	var camera_position = Vector3.ZERO
	
	# Calculate the bob with a sine wave
	camera_position.y = sin(bob_time * bob_frequency) * bob_amplitude
	camera_position.x = cos(bob_time * bob_frequency / 2) * bob_amplitude
	
	return camera_position

func _physics_process(delta):
	# Get input and handle movement
	var input_direction = Input.get_vector("player_left", "player_right", "player_forward", "player_back")
	var direction = (camera_pivot.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	# Determine which speed value to use
	if input_direction.y < 0:
		speed = forward_speed
	else:
		speed = back_speed
	
	# Calculate movement velocity based on moving direction
	velocity.x = lerp(velocity.x, direction.x * speed, delta * 12)
	velocity.z = lerp(velocity.z, direction.z * speed, delta * 12)
	
	# Head bobbing
	bob_time += delta * velocity.length()
	camera.transform.origin = _headbob()
	
	# Move the player
	move_and_slide()
