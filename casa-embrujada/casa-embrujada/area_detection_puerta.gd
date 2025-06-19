extends Area3D

@export  var nodo_puerta: Node3D # Arrastra tu nodo "Puerta" aquí desde el editor
@export  var animador_puerta: AnimationPlayer # Arrastra tu nodo "AnimadorPuerta" aquí
@export var texto_interaccion: Label3D # Opcional: para mostrar "Presiona E para abrir"

# Nueva línea: Referencia al nodo Timer. Asegúrate de que el nombre '$TemporizadorCierrePuerta' coincida con el nombre de tu nodo Timer en el árbol.
@onready var temporizador_cierre_puerta: Timer = $Timer

var jugador_en_area = false
var puerta_abierta = false

func _ready():
	# Conectar las señales del Area3D (si no las conectaste desde el editor, si no, déjalas comentadas)
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)

	# Asegurarse de que los nodos están asignados
	if not nodo_puerta:
		push_error("Error: 'nodo_puerta' no está asignado en el Inspector para el script de la puerta.")
	if not animador_puerta:
		push_error("Error: 'animador_puerta' no está asignado en el Inspector para el script de la puerta.")
	# Nueva verificación para el Timer
	if not temporizador_cierre_puerta:
		push_error("Error: 'temporizador_cierre_puerta' no está asignado o no se encontró el nodo Timer en la ruta '$TemporizadorCierrePuerta'.")

	if texto_interaccion:
		texto_interaccion.visible = false # Ocultar texto al inicio

func _process(delta):
	if jugador_en_area:
		# Detectar la pulsación de la tecla "E" para ABRIR la puerta
		if Input.is_action_just_pressed("interact"): # Asegúrate de tener una acción "interact" en Project Settings
			# Solo abrimos la puerta si está cerrada. El cierre será automático.
			if not puerta_abierta: # Cambiado de 'if puerta_abierta' a 'if not puerta_abierta'
				abrir_puerta()

func _on_body_entered(body):
	# Asegurarse de que el cuerpo que entró es el jugador (por ejemplo, por su grupo)
	if body.is_in_group("player"): # Asegúrate de que tu nodo de jugador esté en el grupo "player"
		jugador_en_area = true
		if texto_interaccion:
			texto_interaccion.visible = true
			if puerta_abierta:
				texto_interaccion.text = "Puerta abierta" # Mensaje para cuando está abierta y no se puede interactuar
			else:
				texto_interaccion.text = "Presiona E para abrir"

func _on_body_exited(body):
	if body.is_in_group("player"):
		jugador_en_area = false
		if texto_interaccion:
			texto_interaccion.visible = false

func abrir_puerta():
	if animador_puerta and not animador_puerta.is_playing():
		animador_puerta.play("Open")
		puerta_abierta = true
		if texto_interaccion:
			texto_interaccion.text = "Puerta abierta" # Cambiado para reflejar que no hay interacción de cierre manual
		
		# ¡Importante! Iniciar el temporizador para que la puerta se cierre automáticamente después de un tiempo
		temporizador_cierre_puerta.start() # Inicia la cuenta regresiva de 2 segundos

func cerrar_puerta():
	# Verifica que el animador exista y que no esté ya reproduciendo una animación
	if animador_puerta and not animador_puerta.is_playing():
		# Reproduce la animación "Open" al revés (asumiendo que "Open" la abre)
		animador_puerta.play_backwards("Open")
		puerta_abierta = false # Actualiza el estado de la puerta
		if texto_interaccion:
			# Si el jugador está en el área, actualiza el texto; si no, se ocultará en _on_body_exited
			if jugador_en_area:
				texto_interaccion.text = "Presiona E para abrir"
			else:
				texto_interaccion.visible = false # Asegurarse de que se oculte si el jugador no está en el área

		# No es necesario detener el temporizador aquí, ya que es "One Shot" y se detiene solo.
		# Además, esta función solo será llamada por el temporizador.


# Esta función SÓLO se llama cuando el TemporizadorCierrePuerta emite la señal 'timeout'

	

func _on_timer_2_timeout() -> void:
# Llama a cerrar_puerta solo si la puerta está abierta (por si acaso).
	if puerta_abierta:
		cerrar_puerta()
