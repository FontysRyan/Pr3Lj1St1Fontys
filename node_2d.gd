extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var custom_tile_names: Dictionary = {}
var zones: int = 1
var rack_ammount: int = 200
var compartment_ammount: int = 5

func _ready():
	await get_tree().create_timer(10.2).timeout
	#Global.rack_amount
	#corner tile locations
	#tile_map_layer.set_cell(Vector2i(0,31), 0, Vector2i(2, 0), 0) #bottom-left
	#tile_map_layer.set_cell(Vector2i(71,0), 0, Vector2i(2, 0), 0) #top-right
	#tile_map_layer.set_cell(Vector2i(71,31), 0, Vector2i(2, 0), 0) #buttom right
	#tile_map_layer.set_cell(Vector2i(0,0), 0, Vector2i(2, 0), 0) #start top-left
	if Global.rack_amount != null && Global.compartment_amount != null:
		rack_ammount = Global.rack_amount
		compartment_ammount = Global.compartment_amount
	if rack_ammount > 100:
		print("WARNING: RACK AMMOUNT OUT RANGE: AUTO RESET TO 100")
		rack_ammount = 100
	if compartment_ammount > 50:
		print("WARNING: cOMPARMENT AMMOUNT OUT RANGE: AUTO RESET TO 50")
		compartment_ammount = 50
	CalculateZone()	
	
func _process(_delta):
		pass

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		var cell_pos = tile_map_layer.local_to_map(mouse_pos)
		var name = custom_tile_names.get(cell_pos, "No name assigned")
		print("Tile clicked at ", cell_pos, " has name: ", name)
	
func CalculateZone():
	var ZoneHeight: int = 4 + compartment_ammount
	var zonewidth: int = calculate_zone_width(rack_ammount)
	print("=== Zone Dimension Calculation ===")
	print("Width Calculation:")
	print("- Total racks: ", rack_ammount)
	print("- Each 2 racks form a 3-tile pattern: [rack, floor, rack]")
	print("- If rack count is odd, it's rounded down to an even number.")
	#print("- There is 1 floor tile before the first rack and 1 after the last.")
	print("- Including walls (1 on each side), this adds 2 extra tiles.")
	print("- Final zone width: ", zonewidth, " tiles\n")
	
	print("Height Calculation:")
	print("- Total compartments: ", compartment_ammount)
	print("- Each compartment adds 1 tile in height.")
	print("- There is 1 floor tile before the first and after the last compartment.")
	print("- Including walls (1 on each side), this adds 4 extra tiles.")
	print("- Final zone height: ", ZoneHeight, " tiles\n")
	
	PlaceWalls(zonewidth, ZoneHeight)
	PlaceFloor(zonewidth, ZoneHeight)
	#PlaceCompartments()
	PlaceRacks()
	
func calculate_zone_width(rank_count: int) -> int:
	var usable_racks = (rank_count / 2) * 2  # Ensure even
	var patterns = usable_racks / 2
	var zone_width = patterns * 3 + 2  # patterns + 2 empty + 2 wall
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

func PlaceRacks():
	var rack_nummer: int = 0
	var compartment_nummer: int = 1
	print("")
	var startpos: int = 1
	for i in range(rack_ammount / 2):
		rack_nummer = rack_nummer + 1
		#print(rack_nummer)
		compartment_nummer = 1
		for a in range(2, compartment_ammount + 2): #1 vertical line of floor
			tile_map_layer.set_cell(Vector2i(startpos,a), 1, Vector2i(1, 2), 0)
			var last_tile_pos = Vector2i(startpos,a)
			custom_tile_names[last_tile_pos] = "Compartment: A_"+ str(rack_nummer) + "_"+ str(compartment_nummer)
			#print("Placed tile at ", startpos, " with name: ", custom_tile_names[last_tile_pos])
			
			tile_map_layer.set_cell(Vector2i(startpos + 2,a), 1, Vector2i(1, 2), 0)
			last_tile_pos = Vector2i(startpos+ 2,a)
			custom_tile_names[last_tile_pos] = "Compartment: A_"+ str(rack_nummer + 1) + "_"+ str(compartment_nummer)
			#print("Placed tile at ", startpos, " with name: ", custom_tile_names[last_tile_pos])
			compartment_nummer = compartment_nummer + 1
		rack_nummer = rack_nummer + 1
		startpos = startpos + 3
		#print(rack_nummer)

#func PlaceCompartments():
	#print("")
	##begin at location 2,2
	##tile_map_layer.set_cell(Vector2i(2,2), 0, Vector2i(0, 0), 0)
	##test_compartment()
	##tile_map_layer.set_cell(Vector2i(4,2), 0, Vector2i(0, 0), 0)
	#
	#var startpos: int = 1
	#for i in range(rack_ammount / 2):
		#for a in range(1, compartment_ammount + 1): #1 vertical line of floor
			#tile_map_layer.set_cell(Vector2i(startpos,a), 1, Vector2i(1, 2), 0)
			#var last_tile_pos = Vector2i(startpos,a)
			#custom_tile_names[last_tile_pos] = "Compartment_A1"+ str(startpos)
			#print("Placed tile at ", startpos, " with name: ", custom_tile_names[last_tile_pos])
			#tile_map_layer.set_cell(Vector2i(startpos + 2,a), 1, Vector2i(1, 2), 0)
		#startpos = startpos + 3
		#print(startpos)
