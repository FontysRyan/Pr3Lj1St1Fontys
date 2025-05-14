extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready():
	#corner tile locations
	tile_map_layer.set_cell(Vector2i(0,31), 0, Vector2i(2, 1), 0)
	tile_map_layer.set_cell(Vector2i(71,0), 0, Vector2i(2, 1), 0)
	tile_map_layer.set_cell(Vector2i(71,31), 0, Vector2i(2, 1), 0)
	tile_map_layer.set_cell(Vector2i(0,0), 0, Vector2i(2, 1), 0)
	#green line
	tile_map_layer.set_cell(Vector2i(27,24), 0, Vector2i(1, 0), 0)
	tile_map_layer.set_cell(Vector2i(27,25), 0, Vector2i(1, 0), 0)
	tile_map_layer.set_cell(Vector2i(27,26), 0, Vector2i(1, 0), 0)
	#purple line
	tile_map_layer.set_cell(Vector2i(29,24), 0, Vector2i(1, 1), 0)
	tile_map_layer.set_cell(Vector2i(29,25), 0, Vector2i(1, 1), 0)
	tile_map_layer.set_cell(Vector2i(29,26), 0, Vector2i(1, 1), 0)

	var i: int = 0

	while i < 31:
		print("i is", i)
		tile_map_layer.set_cell(Vector2i(i,31), 0, Vector2i(2, 1), 0)
		tile_map_layer.set_cell(Vector2i(i,0), 0, Vector2i(2, 1), 0)
		var pos: int = 31 - i
		tile_map_layer.set_cell(Vector2i(0,pos), 0, Vector2i(2, 1), 0)
		i += 1
	i = 0
	while i < 28:
		var pos2: int = 29 - i
		tile_map_layer.set_cell(Vector2i(2,pos2), 0, Vector2i(0, 0), 0)
		i += 1
	
func _process(_delta):
		pass

func _input(event):
	if Input.is_action_just_pressed("click"): 
		print("fffff")
		var grid_pos = tile_map_layer.local_to_map(get_local_mouse_position())
		print(grid_pos)
		tile_map_layer.set_cell(grid_pos, 0, Vector2i(0, 0), 0)
		
