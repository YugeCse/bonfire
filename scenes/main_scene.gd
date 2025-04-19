extends Node

func _ready() -> void:
	var cell_coordinates = $ObjectsLayer.get_used_cells()
	for coordinate in cell_coordinates:
		var data = $ObjectsLayer.get_cell_tile_data(coordinate)
		if data and data.has_custom_data('object_type'):
			print(data.get_custom_data('object_type'))
	$PlayerLifeContainer.current_blood_value = 50.0
	$PlayerLifeContainer.current_magic_value = 20.0
