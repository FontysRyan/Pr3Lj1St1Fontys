extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var zones: int = 1
var rack_ammount: int = 90
var compartment_ammount: int = 29
var shelve_ammount: int = 5
func _ready():
	#corner tile locations
	tile_map_layer.set_cell(Vector2i(0,31), 0, Vector2i(2, 0), 0) #bottom-left
	tile_map_layer.set_cell(Vector2i(71,0), 0, Vector2i(2, 0), 0) #top-right
	tile_map_layer.set_cell(Vector2i(71,31), 0, Vector2i(2, 0), 0) #buttom right
	tile_map_layer.set_cell(Vector2i(0,0), 0, Vector2i(2, 0), 0) #start top-left

	CalculateZone()	
	
func _process(_delta):
		pass

#func _input(event):
	#if Input.is_action_just_pressed("click"): 
		#print("fffff")
		#var grid_pos = tile_map_layer.local_to_map(get_local_mouse_position())
		#print(grid_pos)
		#tile_map_layer.set_cell(grid_pos, 0, Vector2i(0, 0), 0)
func CalculateZone():
	var ZoneHeight: int = 4 + compartment_ammount
	var zonewidth: int = calculate_zone_width(rack_ammount)
	print("=== Zone Dimension Calculation ===")
	print("Width Calculation:")
	print("- Total racks: ", rack_ammount)
	print("- Each 2 racks form a 3-tile pattern: [rack, floor, rack]")
	print("- If rack count is odd, it's rounded down to even.")
	print("- There is 1 floor tile before the first rack and 1 after the last.")
	print("- Including walls (1 on each side), this adds 4 extra tiles.")
	print("- Final zone width: ", zonewidth, " tiles\n")
	
	print("Height Calculation:")
	print("- Total compartments: ", compartment_ammount)
	print("- Each compartment adds 1 tile in height.")
	print("- There is 1 floor tile before the first and after the last compartment.")
	print("- Including walls (1 on each side), this adds 4 extra tiles.")
	print("- Final zone height: ", ZoneHeight, " tiles\n")
	PlaceWalls(zonewidth, ZoneHeight)
	PlaceFloor(zonewidth, ZoneHeight)
	PlaceCompartments()
	
func calculate_zone_width(rank_count: int) -> int:
	var usable_ranks = (rank_count / 2) * 2  # Ensure even
	var patterns = usable_ranks / 2
	var zone_width = patterns * 3 + 2 + 2  # patterns + 2 empty + 2 wall
	return zone_width

func PlaceWalls(with: int, height: int):
	for i in range(with): #horizontalwalls
		tile_map_layer.set_cell(Vector2i(i,0), 0, Vector2i(2, 1), 0)
		var Wall2Pos: int = height - 1
		tile_map_layer.set_cell(Vector2i(i,Wall2Pos), 0, Vector2i(2, 1), 0)
		
	for i in range(height): #verticalwalls
		tile_map_layer.set_cell(Vector2i(0,i), 0, Vector2i(2, 1), 0)
		var Wall2Pos: int = with - 1
		tile_map_layer.set_cell(Vector2i(Wall2Pos,i), 0, Vector2i(2, 1), 0)

func PlaceFloor(with: int, height: int):
	for i in range(1, with - 1):
		for a in range(1, height - 1): #1 vertical line of floor
			tile_map_layer.set_cell(Vector2i(i,a), 1, Vector2i(0, 0), 0)
func PlaceCompartments():
	print("")
	#begin at location 2,2
	tile_map_layer.set_cell(Vector2i(2,2), 0, Vector2i(0, 0), 0)
	tile_map_layer.set_cell(Vector2i(4,2), 0, Vector2i(0, 0), 0)
	var startpos: int = 2
	for i in range(rack_ammount / 2):
		for a in range(2, compartment_ammount + 2): #1 vertical line of floor
			tile_map_layer.set_cell(Vector2i(startpos,a), 1, Vector2i(1, 2), 0)
			tile_map_layer.set_cell(Vector2i(startpos + 2,a), 1, Vector2i(1, 2), 0)
		startpos = startpos + 3
		print(startpos)
