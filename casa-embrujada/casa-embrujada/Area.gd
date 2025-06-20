extends Area3D # ¡Este script está en el Area3D que detectará al jugador!

# Asume que el nodo del jugador está en el grupo "player".
# Puedes cambiar el nombre del grupo si es diferente en tu proyecto.
@export var player_group_name: String = "player"

# Arrastra el AudioStreamPlayer aquí, si no es un hijo directo.
# Si es un hijo directo y se llama "AudioStreamPlayer", puedes usar @onready var sonido_pasos_ambiente_player: AudioStreamPlayer = $AudioStreamPlayer
@export var sonido_pasos_ambiente_player: AudioStreamPlayer

@export var sonido_pasos_ambiente_clip: AudioStream # Arrastra el archivo de sonido aquí (loopable)

var player_is_in_sound_area: bool = false # Para saber si el jugador está dentro del área de activación

# Una referencia al nodo del jugador una vez que entra en el área.
# Esto es útil si necesitas acceder a propiedades específicas del jugador.
var current_player_node: Node3D = null

func _ready():
	# --- Verificaciones iniciales para asegurar que todo está asignado ---

	# Verifica si el AudioStreamPlayer está correctamente asignado
	if not sonido_pasos_ambiente_player:
		push_error("Error: 'sonido_pasos_ambiente_player' (AudioStreamPlayer) no está asignado. Asegúrate de arrastrarlo desde el Inspector.")
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		return

	if not sonido_pasos_ambiente_clip:
		push_warning("Advertencia: 'sonido_pasos_ambiente_clip' no está asignado. El sonido no se escuchará.")

	# Asigna el clip al reproductor de sonido una vez al inicio
	if sonido_pasos_ambiente_player and sonido_pasos_ambiente_clip:
		sonido_pasos_ambiente_player.stream = sonido_pasos_ambiente_clip
		# Asegúrate de que el AudioStreamPlayer esté configurado para LOOP en el Inspector si es un sonido continuo.

	# Conecta las señales body_entered y body_exited de este propio Area3D



func _process(delta):
	# Solo proceder si todos los nodos necesarios están asignados y el script no está deshabilitado
	if sonido_pasos_ambiente_player: # Ya no necesitamos 'player_node' o 'trigger_area' aquí para la verificación principal

		# 'player_is_in_sound_area' se actualiza mediante las funciones conectadas a las señales de este Area3D.

		# Verificar si el jugador está presionando teclas de movimiento
		# Esto asume que el jugador es el que procesa la entrada de movimiento.
		var input_direction_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var player_is_pressing_movement_keys = input_direction_vector.length_squared() > 0.0

		# Lógica para reproducir/detener el sonido
		if player_is_in_sound_area and player_is_pressing_movement_keys:
			if not sonido_pasos_ambiente_player.playing:
				sonido_pasos_ambiente_player.play()
				print("Sonido de pasos ambiente: ON (Jugador en área y moviéndose)")
		else:
			if sonido_pasos_ambiente_player.playing:
				sonido_pasos_ambiente_player.stop()
				print("Sonido de pasos ambiente: OFF (Jugador fuera de área o sin movimiento)")

# Estas funciones serán llamadas por las señales 'body_entered'/'body_exited' de este Area3D
func _on_body_entered(body: Node3D):
	# Comprobamos si el 'body' que entró pertenece al grupo del jugador
	if body.is_in_group(player_group_name):
		player_is_in_sound_area = true
		current_player_node = body # Guardamos una referencia al jugador
		print("Jugador (del grupo '" + player_group_name + "') entró en el área de sonido de pasos.")

func _on_body_exited(body: Node3D):
	# Comprobamos si el 'body' que salió pertenece al grupo del jugador
	if body.is_in_group(player_group_name):
		player_is_in_sound_area = false
		current_player_node = null # Limpiamos la referencia al jugador
		# Detenemos el sonido inmediatamente al salir del área
		if sonido_pasos_ambiente_player.playing:
			sonido_pasos_ambiente_player.stop()
			print("Jugador (del grupo '" + player_group_name + "') salió del área de sonido de pasos. Sonido: OFF")
