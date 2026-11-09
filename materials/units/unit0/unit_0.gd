extends CharacterBody3D

@export var movement_speed: float = 5.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var path_line: MeshInstance3D = $PathLine

var is_selected: bool = false

func _ready() -> void:
	if selection_ring:
		selection_ring.visible = false

func set_target_position(target_pos: Vector3) -> void:
	navigation_agent.target_position = target_pos

func _physics_process(delta: float) -> void:
	# Si llegó al destino, limpiamos la línea y detenemos el movimiento
	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		clear_path_visual()
		return

	# Dibujar la línea de recorrido en tiempo real
	draw_navigation_path()

	# Obtener la siguiente posición del camino
	var current_pos: Vector3 = global_position
	var next_path_pos: Vector3 = navigation_agent.get_next_path_position()

	# Calcular dirección y velocidad
	var direction: Vector3 = (next_path_pos - current_pos).normalized()
	velocity = direction * movement_speed

	# Rotar suavemente hacia el movimiento
	if direction.length() > 0.1:
		var target_look = global_position + Vector3(direction.x, 0, direction.z)
		look_at(target_look, Vector3.UP)

	move_and_slide()

func set_selected(selected: bool) -> void:
	is_selected = selected
	if selection_ring:
		selection_ring.visible = selected
	# Si deseleccionamos la unidad, ocultamos también su línea de recorrido
	if not selected:
		clear_path_visual()

func draw_navigation_path() -> void:
	if not path_line.mesh is ImmediateMesh:
		return
		
	var im: ImmediateMesh = path_line.mesh
	im.clear_surfaces()
	
	# Obtenemos los puntos de la ruta calculada por el NavigationAgent3D
	var points = navigation_agent.get_current_navigation_path()
	if points.size() < 2:
		return
		
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for pt in points:
		# Convertimos la posición global del punto a local de la unidad y lo elevamos un poco para que no se hunda en el suelo
		var local_pt = global_transform.affine_inverse() * pt
		local_pt.y += 0.05 
		im.surface_add_vertex(local_pt)
	im.surface_end()

func clear_path_visual() -> void:
	if path_line and path_line.mesh is ImmediateMesh:
		(path_line.mesh as ImmediateMesh).clear_surfaces()
