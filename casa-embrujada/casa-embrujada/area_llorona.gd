# Script para el AreaMaderaTrigger (adjúntalo al nodo Area3D)
extends Area3D

@export var nodo_madera_a_animar: Node3D # Arrastra el nodo de tu "llorona" aquí (el que contiene el AnimationPlayer)
@export var animador_madera: AnimationPlayer # Arrastra el AnimationPlayer de tu "llorona" aquí

# ¡Nuevas variables para el sonido!
@export var audio_llorona: AudioStreamPlayer # Arrastra tu nodo AudioStreamPlayer3D aquí (ej. "AudioLlorona")
@export var sonido_llorona_clip: AudioStream # Arrastra el archivo de sonido aquí (ej. .wav, .ogg)

var animacion_ya_activada = false # Para asegurar que la animación solo se active una vez

func _ready():
	# --- Verificaciones de Nodos y Recursos ---
	if not nodo_madera_a_animar:
		push_error("Error: 'nodo_madera_a_animar' no está asignado en el Inspector para el script del AreaMaderaTrigger.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return
		
	if not animador_madera:
		push_error("Error: 'animador_madera' no está asignado en el Inspector para el script del AreaMaderaTrigger.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return
	
	if not audio_llorona:
		push_error("Error: 'audio_llorona' (AudioStreamPlayer3D) no está asignado en el Inspector para el script del AreaMaderaTrigger.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return
		
	if not sonido_llorona_clip:
		push_error("Error: 'sonido_llorona_clip' (AudioStream) no está asignado en el Inspector para el script del AreaMaderaTrigger.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return

	# Asegurarse de que la animación 'Aparecer' existe en el animador asignado
	if not animador_madera.has_animation("Aparecer"):
		push_error("Error: La animación 'Aparecer' no existe en el AnimationPlayer asignado para el AreaMaderaTrigger. Verifica el nombre (sensible a mayúsculas/minúsculas).")
		set_process_mode(Node.PROCESS_MODE_DISABLED)


func _on_body_entered(body: Node3D):
	# Verificar si el cuerpo que entró en el área es el jugador (usando su grupo)
	if body.is_in_group("player"):
		if not animacion_ya_activada:
			print("¡Jugador entró en el área de la Llorona! Activando animación 'Aparecer' y sonido.")
			
			# --- Activar Animación ---
			activar_animacion_aparecer()
			animacion_ya_activada = true # Marcar que la animación ya se activó
			
			# --- Activar Sonido ---
			if audio_llorona and sonido_llorona_clip:
				audio_llorona.stream = sonido_llorona_clip # Asigna el clip de sonido
				audio_llorona.play() # Reproduce el sonido
				print("Sonido de la Llorona reproduciéndose.")
			else:
				print("Advertencia: No se pudo reproducir el sonido (AudioStreamPlayer3D o clip no asignado).")


func activar_animacion_aparecer():
	# Solo intentar reproducir si el animador está asignado y tiene la animación
	if animador_madera and animador_madera.has_animation("Aparecer"):
		animador_madera.play("Aparecer")
	else:
		if not animador_madera:
			print("Advertencia: El AnimationPlayer de la Llorona no está asignado.")
		elif not animador_madera.has_animation("Aparecer"):
			print("Advertencia: No se encontró la animación 'Aparecer' en el AnimationPlayer asignado.")


func _on_body_exited(body: Node3D) -> void:
	# Cuando el jugador sale del área
	if body.is_in_group("player"):
		print("Jugador salió del área de la Llorona. Deteniendo sonido.")
		if audio_llorona and audio_llorona.playing:
			audio_llorona.stop() # Detiene el sonido si se está reproduciendo
