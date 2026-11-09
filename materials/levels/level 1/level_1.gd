extends Node3D

var selected_units: Array = []

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var camera = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		
		# Lanzamos un rayo desde la cámara hacia donde apunta el ratón
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result = space_state.intersect_ray(query)
		
		if result:
			var collider = result.collider
			
			# CLIC IZQUIERDO: Seleccionar unidad
			if event.button_index == MOUSE_BUTTON_LEFT:
				# Limpiamos la selección anterior
				for unit in selected_units:
					if is_instance_valid(unit) and unit.has_method("set_selected"):
						unit.set_selected(false)
				selected_units.clear()
				
				# Si hacemos clic en algo del grupo "units"
				if collider.is_in_group("units"):
					selected_units.append(collider)
					collider.set_selected(true)
			
			# CLIC DERECHO: Mover unidades seleccionadas al punto del mapa
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if not selected_units.is_empty():
					var target_position = result.position
					for unit in selected_units:
						if is_instance_valid(unit) and unit.has_method("set_target_position"):
							unit.set_target_position(target_position)
