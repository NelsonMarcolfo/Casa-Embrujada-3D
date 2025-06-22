# Ejemplo para 3D (adaptación del script de Area2D)
extends Area3D

@export var dragon_path: NodePath
@export var player_path: NodePath
@export var camera_path: NodePath

@export var camera_zoom_distance: float = 5.0 # Distancia a la que se acercará la cámara al dragón
@export var zoom_duration: float = 0.5
@export var animation_name: String = "flying_skeletal_3"

var dragon: Node3D
var player: CharacterBody3D
var main_camera: Camera3D
var animation_player: AnimationPlayer

var animation_playing: bool = false
var original_player_can_move: bool = true
var original_camera_transform: Transform3D # Para guardar la transformación original de la cámara

func _ready():
	# Similar a 2D, obtener referencias. Asegúrate de que los tipos sean 3D.
	if dragon_path:
		dragon = get_node(dragon_path)
		if dragon:
			animation_player = dragon.find_child("AnimationPlayer")
			if not animation_player:
				print("Error: No se encontró AnimationPlayer en el dragón.")
				return
	else:
		print("Error: dragon_path no está asignado.")
		return

	if player_path:
		player = get_node(player_path)
		if not player:
			print("Error: No se encontró el nodo del jugador.")
			return

	if camera_path:
		main_camera = get_node(camera_path)
		if not main_camera:
			print("Error: No se encontró el nodo de la cámara.")
			return
	else:
		print("Error: camera_path no está asignado.")
		return

	
	if animation_player:
		animation_player.animation_finished.connect(_on_dragon_animation_finished)

func _on_body_entered(body: Node3D):
	if body == player and not animation_playing:
		animation_playing = true
		print("Jugador entró en el área. Iniciando secuencia del dragón (3D).")
		
		# 1. Detener movimiento del jugador
		if player.has_method("set_can_move"):
			original_player_can_move = player.get_can_move()
			player.set_can_move(false)

		# 2. Guardar estado original de la cámara y acercar
		original_camera_transform = main_camera.transform
		
		# Desactivar la capacidad de la cámara de seguir al jugador temporalmente
		main_camera.set_process(false) # Detener el script de la cámara si maneja seguimiento

		# Calcular la posición de la cámara para el zoom al dragón
		var target_position = dragon.global_position - main_camera.transform.basis.z * camera_zoom_distance
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(main_camera, "global_transform:origin", target_position, zoom_duration)
		tween.tween_property(main_camera, "look_at", dragon.global_position, zoom_duration) # Apuntar al dragón
		
		# 3. Reproducir animación del dragón
		if animation_player.has_animation(animation_name):
			animation_player.play(animation_name)
		else:
			print("Error: La animación '%s' no existe en el AnimationPlayer del dragón." % animation_name)
			_on_dragon_animation_finished(animation_name)

func _on_dragon_animation_finished(anim_name: String):
	if anim_name == animation_name:
		print("Animación del dragón terminada. Restaurando juego (3D).")
		
		# 1. Restaurar movimiento del jugador
		if player.has_method("set_can_move"):
			player.set_can_move(original_player_can_move)

		# 2. Restaurar zoom y posición original de la cámara
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(main_camera, "global_transform", original_camera_transform, zoom_duration)
		tween.tween_callback(func():
			main_camera.set_process(true) # Reactivar el script de la cámara
			animation_playing = false
			queue_free() # Opcional: Eliminar el Area3D
		).set_delay(zoom_duration)
