extends CharacterBody3D

# --- PROPIEDADES EXPORTADAS (AJUSTABLES EN EL EDITOR) ---
@export var speed: float = 10.0 # Velocidad de movimiento (metros por segundo)
@export var jump_velocity: float = 4.5 # Fuerza de salto
@export var mouse_sensitivity: float = 0.002 # Sensibilidad del ratón para mirar

# --- REFERENCIAS A NODOS ---
@onready var camera: Camera3D = $Camera3D
# Referencia a la linterna
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
	# Ocultar el cursor del ratón y bloquearlo al centro de la ventana
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Asegurarse de que la linterna está inicialmente apagada
	if linterna:
		linterna.visible = false
	
	# Asegurarse de que el AudioStreamPlayer3D esté asignado
	# Si tienes varios sonidos, la carga se maneja en 'play_footstep_sound'
	# Si no usas el array exportado, asegúrate de asignar un sonido directamente al footstep_sound_player.stream en el editor.

func _input(event: InputEvent) -> void:
	# Manejar la entrada del ratón para mirar alrededor
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		look_direction.x -= event.relative.x * mouse_sensitivity # Movimiento horizontal (Yaw)
		look_direction.y -= event.relative.y * mouse_sensitivity # Movimiento vertical (Pitch)

		# Limitar la rotación vertical para evitar voltear la cámara (90 grados hacia arriba y abajo)
		look_direction.y = clamp(look_direction.y, deg_to_rad(-90), deg_to_rad(90))

		# Aplicar rotación a los nodos
		# Rotar el CharacterBody3D horizontalmente (Yaw)
		rotation.y = look_direction.x
		# Rotar la Camera3D verticalmente (Pitch)
		camera.rotation.x = look_direction.y
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_Z and event.pressed):
			volver_al_menu()

	# NUEVA LÓGICA: Encender/Apagar la linterna con la tecla F
	if event.is_action_pressed("toggle_flashlight"): # Usaremos una acción de entrada para "F"
		toggle_flashlight()


func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0 # Detener la caída una vez en el suelo

	# Manejar el salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		# NUEVA LÓGICA: Detener sonido de pasos al saltar


	# Obtener la entrada del teclado para el movimiento
	direction = Vector3.ZERO
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Mover en relación a la dirección de la cámara (primera persona)
	var camera_transform = camera.global_transform
	direction = (camera_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Aplicar movimiento
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# NUEVA LÓGICA: Reproducir sonido de pasos si se está moviendo y en el suelo
		if is_on_floor():
			footstep_timer += delta
			if footstep_timer >= footstep_interval:
			
				footstep_timer = 0.0 # Reiniciar el contador para el siguiente paso
	else:
		velocity.x = move_toward(velocity.x, 0, speed) # Frenado suave en X
		velocity.z = move_toward(velocity.z, 0, speed) # Frenado suave en Z
		
		# NUEVA LÓGICA: Detener sonido de pasos si no se está moviendo o está en el aire


	move_and_slide() # Mover y resolver colisiones

# NUEVA FUNCIÓN: Para alternar el estado de la linterna
func toggle_flashlight():
	if linterna: # Asegurarse de que la referencia a la linterna es válida
		linterna_encendida = not linterna_encendida # Invertir el estado
		linterna.visible = linterna_encendida # Aplicar el estado de visibilidad
	else:
		print("Advertencia: No se encontró el nodo de la linterna.")

# --- FUNCIONES PARA SONIDOS DE PASOS (MODIFICADAS) ---
func volver_al_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Mostrar cursor
	get_tree().change_scene_to_file("res://MainMenu.tscn")
