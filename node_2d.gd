# 1 x 1 comparment
# Wil beginnen generen bij 0,31 in vector2i 
# var racks klopt en werkt goed, nu nog alleen compartments. 
# racks worden niet geneneert als tiles, compartments moeten wel. Een rek is verticale rij aan compartments.
# Wat lukt niet: de onderste versie van de muur (zone muur) maar de tweede horizon tale muur gaat fout. Die gaat te hoog of te laag.

# nu nog de width van de zone. height klopt wel.
# zone width moet berekent worden als volgende: 1 comparment (tegen muur) daarna witte space daarna 2 compartments (niet tegen muur) en zo door gaan. Hoewel laatste dan wel tegen muur weer is en daarom de zone muur aan rechterkant ook inplaats nog comparment.
# zone max height is 31. zone max width is 71.
# als compartment te hoog wordt, dan gaat hij spatie en dan naar volgende lijn. Dus bv: zone muur comparment leeg compartment compartment leeg compartment zone muur.

extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var zones: int = 1
var racks: int = 2
var compartments: int = 40
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
	var maxY = 31
	var minY = 0
	var maxX = 71
	var startX = 0
	var currentX = startX

	var usedCompartments = 0
	var compartmentsPerColumn = []

	# 1. Start position for left wall (drawn later)
	var wallXLeft = currentX
	currentX += 1  # space after the left wall for the first compartment

	# 2. Place compartments in columns
	while usedCompartments < compartments and currentX < maxX - 1:
		var columnCompartments = 0
		var currentY = maxY - 1  # below the top wall

		# Place compartments vertically
		while usedCompartments < compartments and currentY >= minY + 1:
			tile_map_layer.set_cell(Vector2i(currentX, currentY), 0, Vector2i(1, 0), 0)
			columnCompartments += 1
			usedCompartments += 1
			currentY -= 2  # compartment + space

		compartmentsPerColumn.append(columnCompartments)
		currentX += 1  # next column

		# skip aisle (1 column whitespace)
		if usedCompartments < compartments and currentX < maxX - 1:
			currentX += 1

	# 3. Right wall comes AFTER the last column
	var wallXRight = currentX

	# 4. Place walls
	tile_map_layer.set_cell(Vector2i(wallXLeft, maxY), 0, Vector2i(2, 1), 0)  # left wall
	tile_map_layer.set_cell(Vector2i(wallXRight, maxY), 0, Vector2i(2, 1), 0)  # right wall

	for x in range(wallXLeft, wallXRight + 1):
		tile_map_layer.set_cell(Vector2i(x, maxY), 0, Vector2i(2, 1), 0)  # top wall
		tile_map_layer.set_cell(Vector2i(x, minY), 0, Vector2i(2, 1), 0)  # bottom wall

	# 5. Debug
	print("Zone from X:", wallXLeft, "to X:", wallXRight)
	print("Total compartments:", usedCompartments)
	print("Compartments per column:", compartmentsPerColumn)
