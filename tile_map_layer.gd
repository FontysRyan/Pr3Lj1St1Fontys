extends TileMapLayer

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var tile_coords = local_to_map(mouse_pos)

		var tile_data = get_cell_tile_data(tile_coords)
		if tile_data:
			var tile_name = tile_data.get_custom_data("name")
			if tile_name:
				print("Je klikte op tile:", tile_name)
			else:
				print("Geen naam gevonden op tile op:", tile_coords)
		else:
			print("Geen tile op:", tile_coords)
