# Script para el AreaSilencioMusical (adjúntalo al nodo Area3D)
extends Area3D

@export var musica_a_silenciar: AudioStreamPlayer
@export var puerta_referencia: Area3D # ¡NUEVO! Arrastra el nodo de tu puerta aquí
@export var fade_duration: float = 1.0 
@export var low_volume_db: float = -80.0 

var tween_actual: Tween = null
var es_jugador_en_area: bool = false # Renombrado para evitar confusión con el grupo "player"
var estado_puerta_actual: bool = false # Para almacenar el estado de la puerta

func _ready():

	if not musica_a_silenciar:
		push_error("Error: 'musica_a_silenciar' no está asignado en el Inspector.")
	
	# NUEVO: Conectar a la señal de la puerta
	if puerta_referencia:
			# Obtener el estado inicial de la puerta
		# Asegúrate de que el script de la puerta tiene una función para esto
		if puerta_referencia.has_method("get_puerta_abierta_estado"): # Tendrás que añadir esta función a la puerta
			estado_puerta_actual = puerta_referencia.get_puerta_abierta_estado()
		else:
			push_error("Error: El script de la puerta no tiene el método 'get_puerta_abierta_estado'.")
	else:
		push_error("Error: 'puerta_referencia' no está asignado en el Inspector.")

func _on_body_entered(body: Node3D):
	if body.is_in_group("player"):
		es_jugador_en_area = true
		evaluar_estado_musica()

func _on_body_exited(body: Node3D):
	if body.is_in_group("player"):
		es_jugador_en_area = false
		evaluar_estado_musica() # Reevaluar si la música debe subir (el jugador salió)

# NUEVO: Función para actualizar el estado de la puerta
func _on_puerta_estado_cambiado(esta_abierta: bool):
	estado_puerta_actual = esta_abierta
	print("Estado de la puerta actualizado: Abierta = {estado_puerta_actual}")
	evaluar_estado_musica() # Reevaluar la música cada vez que la puerta cambia

# NUEVA FUNCIÓN: Lógica central para decidir el volumen de la música
func evaluar_estado_musica():
	# La música bajará solo si el jugador está en el área Y la puerta está CERRADA
	if es_jugador_en_area and not estado_puerta_actual: # <--- ¡Esta es la condición clave!
		print("Condición cumplida: Jugador en área Y puerta cerrada. Bajando volumen.")
		bajar_volumen_musica()
	else:
		print("Condición NO cumplida. Subiendo volumen.")
		subir_volumen_musica()

func bajar_volumen_musica():
	if musica_a_silenciar and musica_a_silenciar.playing:
		if tween_actual and tween_actual.is_running():
			tween_actual.kill()
		
		tween_actual = create_tween()
		tween_actual.tween_property(musica_a_silenciar, "volume_db", low_volume_db, fade_duration)

func subir_volumen_musica():
	if musica_a_silenciar and musica_a_silenciar.stream: 
		if not musica_a_silenciar.playing:
			musica_a_silenciar.play() 
		
		if tween_actual and tween_actual.is_running():
			tween_actual.kill()
		
		tween_actual = create_tween()
		tween_actual.tween_property(musica_a_silenciar, "volume_db", 0.0, fade_duration)
