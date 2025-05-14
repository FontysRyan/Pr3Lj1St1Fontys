extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var zones: int = 1
var racks: int = 1
var compartments: int = 2
var i: int = 0

func _ready():
	
	#corner tile locations

	tile_map_layer.set_cell(Vector2i(71,0), 0, Vector2i(2, 1), 0)
	tile_map_layer.set_cell(Vector2i(71,31), 0, Vector2i(2, 1), 0)
	tile_map_layer.set_cell(Vector2i(0,0), 0, Vector2i(2, 1), 0)
	
	MakeZone()
	
func _process(_delta):
		pass

func _input(event):
	if Input.is_action_just_pressed("click"): 
		print("fffff")
		var grid_pos = tile_map_layer.local_to_map(get_local_mouse_position())
		print(grid_pos)
		tile_map_layer.set_cell(grid_pos, 0, Vector2i(0, 0), 0)
		

func MakeZone():
	var zoneWidth: int = (5 * racks) 
	var zoneHeight: int = (5 * compartments) 
	print(zoneHeight)
	print(zoneWidth)

	for i in range(zoneHeight):
			var Vwall = 31 - i
			var Vwall2 = 4 * racks
			tile_map_layer.set_cell(Vector2i(0,Vwall), 0, Vector2i(2, 1), 0) #start
			tile_map_layer.set_cell(Vector2i(Vwall2,Vwall), 0, Vector2i(2, 1), 0) #start
			i + 1
	for i in range(zoneWidth):
			var Hwall = 0 + i
			var Hwall2 = 31 - (4 * compartments)
			tile_map_layer.set_cell(Vector2i(Hwall,31), 0, Vector2i(2, 1), 0) #start
			tile_map_layer.set_cell(Vector2i(Hwall,Hwall2), 0, Vector2i(2, 1), 0) #start
			i + 1
