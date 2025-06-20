# Script para el AreaMaderaTrigger (adjúntalo al nodo Area3D)
extends Area3D

@export var nodo_madera_a_animar: Node3D # Arrastra el nodo de tu "madera" aquí (el que contiene el AnimationPlayer)
@export var animador_madera: AnimationPlayer # Arrastra el AnimationPlayer de tu "madera" aquí

var animacion_ya_activada = false # Para asegurar que la animación solo se active una vez

func _ready():
	# No necesitamos body_exited para este caso, ya que queremos que la caída sea definiti
	# Verificaciones para asegurar que los nodos están asignados
	if not nodo_madera_a_animar:
		push_error("Error: 'nodo_madera_a_animar' no está asignado en el Inspector para el script del AreaMaderaTrigger.")
	if not animador_madera:
		push_error("Error: 'animador_madera' no está asignado en el Inspector para el script del AreaMaderaTrigger.")
	
	# Asegurarse de que la animación 'caida' existe en el animador
	if animador_madera and not animador_madera.has_animation("Caida"):
		push_error("Error: La animación 'caida' no existe en el AnimationPlayer asignado para el AreaMaderaTrigger.")


func _on_body_entered(body: Node3D):
	# Verificar si el cuerpo que entró en el área es el jugador (usando su grupo)
	if body.is_in_group("player"):
		if not animacion_ya_activada:
			print("¡Jugador entró en el área de madera! Activando animación 'caida'.")
			activar_animacion_caida()
			animacion_ya_activada = true # Marcar que la animación ya se activó


func activar_animacion_caida():
	if animador_madera:
		if animador_madera.has_animation("Caida"):
			animador_madera.play("Caida")
		else:
			print("Advertencia: No se encontró la animación 'caida' en el AnimationPlayer asignado.")
	else:
		print("Advertencia: El AnimationPlayer de la madera no está asignado.")
