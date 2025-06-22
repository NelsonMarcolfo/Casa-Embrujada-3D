# Script: AreaLloronaTrigger.gd
extends Area3D

@export var llorona_path: NodePath # Arrastra el nodo de la Llorona aquí
@export var player_camera_path: NodePath # Arrastra el nodo Camera3D de tu jugador aquí
@export var player_group_name: String = "player" # Nombre del grupo del jugador

@export var susto_animation_name: String = "Sustos" # Nombre de la animación de susto de la Llorona
@export var camera_zoom_fov: float = 40.0 # Valor del FOV para el acercamiento de la cámara (FOV normal suele ser 75)
@export var zoom_duration: float = 0.8 # Duración del acercamiento y alejamiento de la cámara
@export var llorona_animation_player: AnimationPlayer
var llorona: Node3D

var player_camera: Camera3D
var original_camera_fov: float # Para guardar el FOV original de la cámara

var has_triggered: bool = false # Para asegurar que solo se active una vez

func _ready():
	# Validar y obtener referencias a los nodos
	if not llorona_path:
		print("Error: 'llorona_path' no está asignado en 'Areallorona'.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return
	llorona = get_node(llorona_path)
	if not llorona:
		print("Error: No se encontró el nodo de la Llorona en la ruta especificada.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return
	llorona_animation_player = llorona.find_child("AnimationPlayer")
	if not llorona_animation_player:
		print("Error: No se encontró un AnimationPlayer como hijo de la Llorona.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return

	if not player_camera_path:
		print("Error: 'player_camera_path' no está asignado en 'Areallorona'.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return
	player_camera = get_node(player_camera_path)
	if not player_camera:
		print("Error: No se encontró la Camera3D del jugador en la ruta especificada.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return

	original_camera_fov = player_camera.fov # Guardar el FOV original de la cámara

	# Conectar la señal de entrada del cuerpo

func _on_body_entered(body: Node3D):
	# Verificar si es el jugador y si no se ha activado ya
	if body.is_in_group(player_group_name) and not has_triggered:
		has_triggered = true
		print("El jugador ha entrado en Areallorona. Iniciando secuencia de susto...")
		
		# 1. Reproducir la animación de susto de la Llorona
		if llorona_animation_player.has_animation(susto_animation_name):
			llorona_animation_player.play(susto_animation_name)
		else:
			print("Advertencia: La animación '%s' no existe en el AnimationPlayer de la Llorona." % susto_animation_name)
		
		# 2. Animar el acercamiento y alejamiento de la cámara del jugador (FOV)
		var camera_tween = create_tween()
		camera_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# Acercamiento (FOV disminuye para hacer zoom in)
		camera_tween.tween_property(player_camera, "fov", camera_zoom_fov, zoom_duration)
		
		# Esperar un momento y luego alejarse (FOV vuelve a su valor original)
		camera_tween.tween_interval(llorona_animation_player.get_animation(susto_animation_name).length - zoom_duration * 1.5) # Ajusta este intervalo
		
		camera_tween.set_ease(Tween.EASE_IN)
		camera_tween.tween_property(player_camera, "fov", original_camera_fov, zoom_duration)
		
		# Opcional: Esperar a que la animación de la Llorona termine antes de eliminar el Area3D
		await llorona_animation_player.animation_finished
		print("Animación de susto terminada. Secuencia completada.")
		queue_free() # Eliminar el Area3D para que no se active de nuevo
