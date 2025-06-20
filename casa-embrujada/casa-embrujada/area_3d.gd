extends Area3D

@export var nodo_puerta: Node3D # Arrastra tu nodo "Puerta" aquí desde el editor
@export var animador_puerta: AnimationPlayer # Arrastra tu nodo "AnimadorPuerta" aquí
@export var texto_interaccion: Label3D # Opcional: para mostrar "Presiona E para abrir"

# Variables para el sonido de la puerta
@export var audio_puerta_player: AudioStreamPlayer # Renombrado para claridad
@export var sonido_abrir_puerta: AudioStream # Sonido para cuando la puerta se abre
@export var sonido_cerrar_puerta: AudioStream # Sonido para cuando la puerta se cierra

# Referencia al nodo Timer. Asegúrate de que el nombre '$Timer' coincida.
@onready var temporizador_cierre_puerta: Timer = $Timer

var jugador_en_area = false
var puerta_abierta = false

func _ready():
	# Asegurarse de que los nodos están asignados
	if not nodo_puerta:
		push_error("Error: 'nodo_puerta' no está asignado en el Inspector para el script de la puerta.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
	if not animador_puerta:
		push_error("Error: 'animador_puerta' no está asignado en el Inspector para el script de la puerta.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
	if not temporizador_cierre_puerta:
		push_error("Error: 'temporizador_cierre_puerta' no está asignado o no se encontró el nodo Timer en la ruta '$Timer'.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	# Verificaciones para los nuevos nodos de audio
	if not audio_puerta_player:
		push_error("Error: 'audio_puerta_player' no está asignado en el Inspector.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
	if not sonido_abrir_puerta:
		push_error("Advertencia: 'sonido_abrir_puerta' no está asignado. La puerta se abrirá en silencio.")
	if not sonido_cerrar_puerta:
		push_error("Advertencia: 'sonido_cerrar_puerta' no está asignado. La puerta se cerrará en silencio.")

	# Opcional: Verificar que las animaciones existan
	if animador_puerta:
		if not animador_puerta.has_animation("Open"):
			push_error("Error: Animación 'Open' no encontrada en 'animador_puerta'.")
			set_process_mode(Node.PROCESS_MODE_DISABLED)
		# Suponemos que "Open" se usa también para cerrar con play_backwards
	
	if texto_interaccion:
		texto_interaccion.visible = false # Ocultar texto al inicio

func _process(delta):
	if jugador_en_area:
		# Detectar la pulsación de la tecla "E" para ABRIR la puerta
		if Input.is_action_just_pressed("interact"): 
			if not puerta_abierta:
				abrir_puerta()

func _on_body_entered(body):
	if body.is_in_group("player"): 
		jugador_en_area = true
		if texto_interaccion:
			# Mostrar el texto de interacción si la puerta está cerrada
			if not puerta_abierta:
				texto_interaccion.visible = true
				texto_interaccion.text = "Presiona E para abrir"
			else: # Si ya está abierta, no mostrar texto de interacción inicial.
				texto_interaccion.visible = false # Ocultar o mostrar un texto diferente si la puerta ya está abierta

func _on_body_exited(body):
	if body.is_in_group("player"):
		jugador_en_area = false
		if texto_interaccion:
			texto_interaccion.visible = false
		
		# Detenemos el sonido solo si es un sonido continuo que queremos parar al salir
		# Si es un chirrido corto, ya habrá terminado.
		if audio_puerta_player and audio_puerta_player.playing:
			audio_puerta_player.stop()

func abrir_puerta():
	if animador_puerta and not animador_puerta.is_playing():
		animador_puerta.play("Open")
		puerta_abierta = true
		if texto_interaccion:
			texto_interaccion.text = "Puerta abierta"
		
		# --- Reproducir sonido al ABRIR ---
		if audio_puerta_player and sonido_abrir_puerta:
			audio_puerta_player.stream = sonido_abrir_puerta
			audio_puerta_player.play()
			print("Sonido de apertura de puerta reproduciéndose.")
		
		temporizador_cierre_puerta.start() # Inicia la cuenta regresiva para cerrar automáticamente

func cerrar_puerta():
	if animador_puerta and not animador_puerta.is_playing():
		animador_puerta.play_backwards("Open")
		puerta_abierta = false 
		if texto_interaccion:
			if jugador_en_area: # Si el jugador sigue en el área al cerrarse
				texto_interaccion.text = "Presiona E para abrir"
			else: # Si el jugador ya salió
				texto_interaccion.visible = false 
		
		# --- Reproducir sonido al CERRAR ---
		if audio_puerta_player and sonido_cerrar_puerta:
			audio_puerta_player.stream = sonido_cerrar_puerta
			audio_puerta_player.play()
			print("Sonido de cierre de puerta reproduciéndose.")

# Esta función se llama cuando el TemporizadorCierrePuerta emite la señal 'timeout'
func _on_Timer_timeout() -> void: # Asegúrate de que este nombre coincida con la señal conectada
	if puerta_abierta: # Solo cierra si está abierta
		cerrar_puerta()

func get_puerta_abierta_estado() -> bool:
	return puerta_abierta
