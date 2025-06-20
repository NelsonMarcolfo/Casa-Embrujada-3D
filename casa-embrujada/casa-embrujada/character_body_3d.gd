extends CharacterBody3D

# --- PROPIEDADES EXPORTADAS ---
@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var footstep_interval: float = 0.4
@export var footstep_sounds: Array[AudioStream]

# --- REFERENCIAS A NODOS ---
@onready var camera: Camera3D = $Camera3D
Graphic-interface
@onready var linterna: SpotLight3D = $Camera3D/Linterna

# --- VARIABLES INTERNAS ---
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3 = Vector3.ZERO
var look_direction: Vector2 = Vector2.ZERO
var linterna_encendida: bool = false
var is_footstep_sound_playing: bool = false
var footstep_timer: float = 0.0# Referencia a la linterna
@onready var linterna: SpotLight3D = $Camera3D/Linterna # Asegúrate de que esta ruta sea correcta
# NUEVA LÍNEA: Referencia al AudioStreamPlayer3D para los sonidos de los pasos # Asegúrate de que esta ruta sea correcta

# Opcional: Si tienes varios sonidos de pasos para variedad
@export var footstep_sounds: Array[AudioStream] # Arrastra tus archivos de sonido aquí en el Inspector

# --- VARIABLES INTERNAS DE LÓGICA ---
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") # Gravedad del proyecto
var direction: Vector3 = Vector3.ZERO # Dirección de movimiento del jugador
var look_direction: Vector2 = Vector2.ZERO # Dirección de la mirada (ángulos de la cámara)

# Estado de la linterna
var linterna_encendida: bool = false

# NUEVA LÍNEA: Controla si el sonido de pasos ya se está reproduciendo
var is_footstep_sound_playing: bool = false
# NUEVA LÍNEA: Frecuencia de los pasos (cuántos pasos por segundo se escucharán)
@export var footstep_interval: float = 0.4 # Un paso cada 0.4 segundos (ajusta según la velocidad)
var footstep_timer: float = 0.0 # Timer interno para controlar la frecuencia de los pasos



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if linterna:
		linterna.visible = false
	
	# Asegurarse de que el AudioStreamPlayer3D esté asignado
	# Si tienes varios sonidos, la carga se maneja en 'play_footstep_sound'
	# Si no usas el array exportado, asegúrate de asignar un sonido directamente al footstep_sound_player.stream en el editor.

func _input(event: InputEvent) -> void:
	# Rotación de la cámara
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		look_direction.x -= event.relative.x * mouse_sensitivity
		look_direction.y -= event.relative.y * mouse_sensitivity
		look_direction.y = clamp(look_direction.y, deg_to_rad(-90), deg_to_rad(90))

		rotation.y = look_direction.x		# Aplicar rotación a los nodos
		# Rotar el CharacterBody3D horizontalmente (Yaw)
		rotation.y = look_direction.x
		# Rotar la Camera3D verticalmente (Pitch)
		camera.rotation.x = look_direction.y

	# Linterna (tecla F)
	if event.is_action_pressed("toggle_flashlight"):
		toggle_flashlight()
	
	# Volver al menú con Z o ESC
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_Z and event.pressed):
			volver_al_menu()

func _physics_process(delta: float) -> void:
	# Gravedad y salto
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		# NUEVA LÓGICA: Detener sonido de pasos al saltar


	# Movimiento
	direction = Vector3.ZERO
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
  
	var camera_transform = camera.global_transform
	direction = (camera_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
    

		if is_on_floor():
			footstep_timer += delta
			if footstep_timer >= footstep_interval:
				footstep_timer = 0.0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func toggle_flashlight():
	if linterna:
		linterna_encendida = !linterna_encendida
		linterna.visible = linterna_encendida
	else:
		print("Advertencia: No se encontró la linterna.")

func volver_al_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Mostrar cursor
	get_tree().change_scene_to_file("res://MainMenu.tscn")

