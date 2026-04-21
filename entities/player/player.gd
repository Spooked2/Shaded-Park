extends CharacterBody3D

var speed: float = 6.65
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_direction: Vector2 = Vector2()
var mouse_sensitivity: float = 17.5

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	_toggle_mouse_capture()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	_rotate_camera(delta, 1.0)
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_direction = event.relative * 0.01
	
	if event.is_action_pressed("escape"):
		_toggle_mouse_capture()

func _rotate_camera(delta: float, sensitivity_mod: float) -> void:
	rotation.y -= look_direction.x * mouse_sensitivity * delta
	
	var camera_rotation_clamp_value: float = camera.rotation.x - look_direction.y * mouse_sensitivity * sensitivity_mod * delta
	
	camera.rotation.x = clamp(camera_rotation_clamp_value, -1.5, 1.5)
	
	look_direction = Vector2.ZERO
	

func _toggle_mouse_capture() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
