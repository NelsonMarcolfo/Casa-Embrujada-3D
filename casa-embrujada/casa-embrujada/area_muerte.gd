extends Area3D

@export var muerte_character_path: NodePath # Arrastra aquí el nodo padre de "Muerte"
@export var fade_animation_name: String = "Desvanecer" # Nombre de la animación de desvanecimiento
@export var fade_delay: float = 0.0 # Retraso antes de que empiece el desvanecimiento
@export var player_group_name: String = "player" # ¡NUEVO! Nombre del grupo del jugador
@export var animation_player: AnimationPlayer
var muerte_character: Node3D

var has_triggered: bool = false # Para asegurar que solo se active una vez

func _ready():
	# Obtener referencia al personaje "Muerte"
	if muerte_character_path:
		muerte_character = get_node(muerte_character_path)
		if not muerte_character:
			print("Error: No se encontró el personaje 'Muerte' en la ruta especificada.")
			set_process_mode(Node.PROCESS_MODE_DISABLED) # Desactivar script si no se encuentra
			return
		# Buscar el AnimationPlayer como hijo de "Muerte"
		animation_player = muerte_character.find_child("AnimationPlayer")
		if not animation_player:
			print("Error: No se encontró un nodo AnimationPlayer como hijo de 'Muerte'.")
			set_process_mode(Node.PROCESS_MODE_DISABLED)
			return
	else:
		print("Error: 'muerte_character_path' no está asignado. Asigna el nodo 'Muerte' en el Inspector.")
		set_process_mode(Node.PROCESS_MODE_DISABLED) # Desactivar script si no está asignado
		return


func _on_body_entered(body: Node3D):
	# ¡CAMBIO AQUÍ! Usar is_in_group() para verificar si el cuerpo pertenece al grupo del jugador
	if body.is_in_group(player_group_name) and not has_triggered:
		has_triggered = true
		print("El jugador ha entrado en el área. Iniciando animación de desvanecimiento de Muerte...")
		if fade_delay > 0:
			await get_tree().create_timer(fade_delay).timeout
		_start_fade_animation()

func _start_fade_animation():
	if animation_player and animation_player.has_animation(fade_animation_name):
		animation_player.play(fade_animation_name)
		animation_player.animation_finished.connect(_on_fade_animation_finished)
	else:
		print("Error: No se encontró la animación '%s' en el AnimationPlayer de Muerte." % fade_animation_name)

func _on_fade_animation_finished(anim_name: String):
	if anim_name == fade_animation_name:
		print("Animación de desvanecimiento de Muerte terminada. Eliminando nodo.")
		if muerte_character:
			muerte_character.queue_free()
		queue_free()
		animation_player.animation_finished.disconnect(_on_fade_animation_finished)

func _find_mesh_instance_recursive(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found_mesh = _find_mesh_instance_recursive(child)
		if found_mesh:
			return found_mesh
	return null
