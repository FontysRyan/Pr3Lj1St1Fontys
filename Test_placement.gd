extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var custom_tile_names: Dictionary = {}

func _ready():
	var pos: int = 1
	var tile_coords = Vector2i(0, 0)
	var layer = 0
	var flags = 0
	for i in range(5):
		print(i)
		# Place tile at (2,2)
		tile_map_layer.set_cell(Vector2i(pos, 2), layer, tile_coords, flags)
		var last_tile_pos = Vector2i(pos,2)
		custom_tile_names[last_tile_pos] = "Compartment_A1"+ str(pos)
		print("Placed tile at ", pos, " with name: ", custom_tile_names[last_tile_pos])
		pos = pos + 1

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var cell_pos = tile_map_layer.local_to_map(mouse_pos)
		var name = custom_tile_names.get(cell_pos, "No name assigned")
		print("Tile clicked at ", cell_pos, " has name: ", name)
