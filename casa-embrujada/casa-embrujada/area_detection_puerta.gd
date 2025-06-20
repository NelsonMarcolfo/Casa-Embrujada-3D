extends Area3D

@export var nodo_puerta1: Node3D # Arrastra tu nodo "Puerta" aquí desde el editor (Ej. Puerta2D, PuertaPrincipal)
@export var animador_puerta1: AnimationPlayer # Arrastra el AnimationPlayer de esta puerta aquí (Ej. AnimadorPuerta2)
@export var texto_interaccion1: Label3D # Opcional: para mostrar "Presiona E para abrir"

# Variables para el sonido de esta puerta específica
@export var audio_puerta_player1: AudioStreamPlayer # Nodo AudioStreamPlayer para los sonidos de esta puerta
@export var sonido_abrir_puerta1: AudioStream # Archivo de sonido para cuando esta puerta se abre
@export var sonido_cerrar_puerta1: AudioStream # Archivo de sonido para cuando esta puerta se cierra

# Referencia al nodo Timer. Asegúrate de que el nombre '$Timer' coincida con el nombre de tu nodo Timer hijo de esta Area3D.
@onready var temporizador_cierre_puerta: Timer = $Timer

var jugador_en_area1 = false
var puerta_abierta = false

func _ready():
	# Asegurarse de que los nodos están asignados en el Inspector
	if not nodo_puerta1:
		push_error("Error: 'nodo_puerta1' no está asignado en el Inspector para el script de esta puerta.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return # Salir temprano si falta un nodo crucial
	if not animador_puerta1:
		push_error("Error: 'animador_puerta1' no está asignado en el Inspector para el script de esta puerta.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return
	if not temporizador_cierre_puerta:
		push_error("Error: 'temporizador_cierre_puerta' no está asignado o no se encontró el nodo Timer en la ruta '$Timer' para esta puerta.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return
	
	# Verificaciones para los nodos de audio de esta puerta
	if not audio_puerta_player1:
		push_error("Error: 'audio_puerta_player1' no está asignado en el Inspector para esta puerta.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return
	if not sonido_abrir_puerta1:
		push_warning("Advertencia: 'sonido_abrir_puerta1' no está asignado para esta puerta. Se abrirá en silencio.") # Cambiado a push_warning
	if not sonido_cerrar_puerta1:
		push_warning("Advertencia: 'sonido_cerrar_puerta1' no está asignado para esta puerta. Se cerrará en silencio.") # Cambiado a push_warning

	# Opcional: Verificar que las animaciones existan en el animador de esta puerta
	if animador_puerta1:
		if not animador_puerta1.has_animation("Open"): # Asumiendo que la animación de apertura se llama "Open"
			push_error("Error: Animación 'Open' no encontrada en 'animador_puerta1' para esta puerta. Asegúrate de que existe y el nombre es correcto.")
			set_process_mode(Node.PROCESS_MODE_DISABLED)
		# Suponemos que la animación de cierre es "Open" reproducida al revés (`play_backwards`)
	
	if texto_interaccion1:
		texto_interaccion1.visible = false # Ocultar texto al inicio

func _process(delta):
	if jugador_en_area1:
		# Detectar la pulsación de la tecla "E" para ABRIR la puerta
		if Input.is_action_just_pressed("interact"): # Asegúrate de tener una acción "interact" en Project Settings
			if not puerta_abierta: # Solo abrimos la puerta si está cerrada
				abrir_puerta()

func _on_body_entered(body):
	# Asegurarse de que el cuerpo que entró es el jugador (por ejemplo, por su grupo "player")
	if body.is_in_group("player"): 
		jugador_en_area1 = true
		if texto_interaccion1:
			# Mostrar el texto de interacción si la puerta está cerrada
			if not puerta_abierta:
				texto_interaccion1.visible = true
				texto_interaccion1.text = "Presiona E para abrir"
			else: # Si ya está abierta, no mostrar texto de interacción para abrir
				texto_interaccion1.visible = false # Ocultar texto si la puerta ya está abierta


func _on_body_exited(body):
	if body.is_in_group("player"):
		jugador_en_area1 = false
		if texto_interaccion1:
			texto_interaccion1.visible = false
		# Detenemos el sonido solo si es un sonido continuo que queremos parar al salir
		# Si es un chirrido corto, ya habrá terminado y no necesita stop().
		if audio_puerta_player1 and audio_puerta_player1.playing:
			audio_puerta_player1.stop()

func abrir_puerta():
	# Solo abre si el animador está asignado y no está ya reproduciendo una animación
	if animador_puerta1 and not animador_puerta1.is_playing():
		animador_puerta1.play("Open")
		puerta_abierta = true
		if texto_interaccion1:
			texto_interaccion1.text = "Puerta abierta"
		
		# --- Reproducir sonido al ABRIR ---
		if audio_puerta_player1 and sonido_abrir_puerta1:
			audio_puerta_player1.stream = sonido_abrir_puerta1
			audio_puerta_player1.play()
			print("Sonido de apertura de la puerta 1 reproduciéndose.")
		
		temporizador_cierre_puerta.start() # Inicia la cuenta regresiva para el cierre automático

func cerrar_puerta():
	# Solo cierra si el animador está asignado y no está ya reproduciendo una animación
	if animador_puerta1 and not animador_puerta1.is_playing():
		animador_puerta1.play_backwards("Open") # Reproduce la animación "Open" al revés para cerrar
		puerta_abierta = false 
		if texto_interaccion1:
			if jugador_en_area1: # Si el jugador sigue en el área al cerrarse
				texto_interaccion1.text = "Presiona E para abrir"
			else: # Si el jugador ya salió del área
				texto_interaccion1.visible = false 
		
		# --- Reproducir sonido al CERRAR ---
		if audio_puerta_player1 and sonido_cerrar_puerta1:
			audio_puerta_player1.stream = sonido_cerrar_puerta1
			audio_puerta_player1.play()
			print("Sonido de cierre de la puerta 1 reproduciéndose.")

# Esta función se llama cuando el TemporizadorCierrePuerta emite la señal 'timeout'
# Asegúrate de que esta función esté conectada a la señal 'timeout()' del nodo Timer
func _on_Timer_timeout() -> void: 
	if puerta_abierta: # Solo cierra si la puerta está abierta
		cerrar_puerta()

# Función para que otros scripts puedan consultar el estado actual de la puerta
func get_puerta_abierta_estado() -> bool:
	return puerta_abierta

# IMPORTANTE: Elimina esta función duplicada si no la estás usando para otra cosa.
# Solo debe haber una función _on_Timer_timeout() conectada a la señal del Timer.
# func _on_timer_timeout() -> void:
# 	pass # Replace with function body.
