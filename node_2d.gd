extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready():
	tile_map_layer.set_cell(Vector2i(0,31), 0, Vector2i(2, 1), 0)
	tile_map_layer.set_cell(Vector2i(71,0), 0, Vector2i(2, 1), 0)
	tile_map_layer.set_cell(Vector2i(71,31), 0, Vector2i(2, 1), 0)
	tile_map_layer.set_cell(Vector2i(0,0), 0, Vector2i(2, 1), 0)
	tile_map_layer.set_cell(Vector2i(27,24), 0, Vector2i(1, 0), 0)
	tile_map_layer.set_cell(Vector2i(27,25), 0, Vector2i(1, 0), 0)
	tile_map_layer.set_cell(Vector2i(27,26), 0, Vector2i(1, 0), 0)
	tile_map_layer.set_cell(Vector2i(29,24), 0, Vector2i(1, 1), 0)
	tile_map_layer.set_cell(Vector2i(29,25), 0, Vector2i(1, 1), 0)
	tile_map_layer.set_cell(Vector2i(29,26), 0, Vector2i(1, 1), 0)
	
func _process(_delta):
		pass

func _input(event):
	if Input.is_action_just_pressed("click"): 
		print("fffff")
		var grid_pos = tile_map_layer.local_to_map(get_local_mouse_position())
		print(grid_pos)
		tile_map_layer.set_cell(grid_pos, 0, Vector2i(0, 0), 0)
		
