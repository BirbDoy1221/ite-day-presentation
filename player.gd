extends CharacterBody3D


@export var speed : float = 5.0
const JUMP_VELOCITY : float = 4.5
const SENSITIVITY : float = 0.0015

@onready var head : Node3D = $Head
@onready var camera : Camera3D = $Head/Camera3D

func set_mouse_mode(capture : bool = false) -> void:
	if capture:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	set_mouse_mode(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	# Handle jump.
	if not is_on_floor():
		velocity += get_gravity() * delta
						
	
	if Input.is_action_just_pressed("ui_cancel"):
		set_mouse_mode()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir : Vector2 = Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
	var direction : Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
