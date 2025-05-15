extends Node

var latest_data
var current_table: String = ""

# --- Data storage ---
var zones_data: Array = []
var racks_data: Array = []
var shelves_data: Array = []
var compartments_data: Array = []
var items_data: Array = []

var rack_amount
var compartment_amount
var shelve_amount

func _ready() -> void:	
	#post_data("http://192.168.133.123:5000/insert/warehouses", {
		#"name" : "Main warehouse",
		#"city" : "Eindhoven",
		#"address" : "Test straat 17",
		#"postal_code" : "1234AB"
	#})
	
	#post_data("http://192.168.133.123:5000/insert/zones", {
		#"warehouse_id" : 1,
		#"zone_name" : "A",
		#"zone_type" : "storage"
	#})
	
	#insert_x_times_racks(43)
	insert_x_times_compartments(100)
	
	#await load_all_data_from_db()
	#rack_amount = get_rack_amount()
	#print(rack_amount)
	
	
	
#func _on_data_received(data):
	#print("Received data: " + data)
	#latest_data = data

var rack_queue: Array = []
var current_index: int = 0
var sending: bool = false

func get_rack_amount():
	return len(racks_data)
# --- Load all data from mysql database ---
func load_all_data_from_db():
	current_table = "zones"
	get_data("zones")
	await get_tree().create_timer(0.2).timeout
		
	current_table = "racks"
	get_data("racks")
	await get_tree().create_timer(0.2).timeout
	
	current_table = "shelves"
	get_data("shelves")
	await get_tree().create_timer(0.2).timeout

	current_table = "compartments"
	get_data("compartments")
	await get_tree().create_timer(0.2).timeout

	current_table = "products"
	get_data("products")
	await get_tree().create_timer(0.2).timeout

# --- Meerder racks invoegen ---
func insert_x_times_racks(x: int) -> void:
	rack_queue.clear()
	for i in range(x):
		rack_queue.append({
			"zone_id": 1,
			"rack_number": str(i + 1),
			"capacity": 1
		})
	current_index = 0
	sending = true
	_send_next_rack()

# --- Actually sending the rack ---
func _send_next_rack() -> void:
	if current_index < rack_queue.size():
		var data = rack_queue[current_index]
		post_data("http://192.168.133.123:5000/insert/racks", data)
	else:
		print("All racks inserted.")
		sending = false


var compartment_queue: Array = []
var current_compartment_index: int = 0
var sending_compartments: bool = false

# --- Insert X amount of compartments into the mysql database
func insert_x_times_compartments(x: int) -> void:
	compartment_queue.clear()
	for i in range(43):
		for n in range(x):
			compartment_queue.append({
				"zone_id": 1,  # adjust this as needed
				"compartment_number": "Rack: " + str(i + 1) + " Compartment: " + str(n + 1)
			})
	current_compartment_index = 0
	sending_compartments = true
	_send_next_compartment()

# --- Actually sending the rack ---
func _send_next_compartment() -> void:
	if current_compartment_index < compartment_queue.size():
		var data = compartment_queue[current_compartment_index]
		print("Sending compartment ", current_compartment_index + 1, ": ", data)
		post_data("http://192.168.133.123:5000/insert/compartments", data)
	else:
		print("All compartments inserted.")
		sending_compartments = false

# --- POST functie ---
func post_data(url: String, data: Dictionary) -> void:
	var http = $HTTPRequest
	var headers = ["Content-Type: application/json"]
	var json_data = JSON.stringify(data)
	
	var result = http.request(url, PackedStringArray(headers), HTTPClient.METHOD_POST, json_data)
	if result != OK:
		print("POST request failed to start: ", result)

# --- GET functie ---
func get_data(table_name: String) -> void:
	current_table = table_name  # Store the context
	var http = $HTTPRequest
	var url = "http://192.168.133.123:5000/select/" + table_name
	
	var headers = PackedStringArray()
	var result = http.request(url, headers, HTTPClient.METHOD_GET)
	
	if result != OK:
		print("GET request failed: ", result)
	else:
		print("GET request sent successfully for table: ", table_name)

# --- Callback bij voltooid verzoek ---
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Response code: ", response_code)
	var text = body.get_string_from_utf8()
	print("Response body: ", text)

	var parsed = JSON.parse_string(text)
	if parsed == null:
		print("Kon JSON niet parsen.")
		return

	# Store parsed array data in the correct variable based on current_table
	if typeof(parsed) == TYPE_ARRAY:
		match current_table:
			"zones":
				zones_data = parsed
				print("Zones opgeslagen: ", zones_data)
			"racks":
				racks_data = parsed
				print("Racks opgeslagen: ", racks_data)
			"shelves":
				shelves_data = parsed
				print("Shelves opgeslagen: ", shelves_data)
			"compartments":
				compartments_data = parsed
				print("Compartments opgeslagen: ", compartments_data)
			"items":
				items_data = parsed
				print("Items opgeslagen: ", items_data)
			_:
				print("Onbekende tabel: ", current_table)

	# Continue queue logic if needed
	if sending:
		current_index += 1
		_send_next_rack()
	elif sending_compartments:
		current_compartment_index += 1
		_send_next_compartment()

# --- Data Handlers ---
func handle_zones(data):
	zones_data = data
	print("Zones opgeslagen: ", zones_data)

func handle_racks(data):
	racks_data = data
	print("Racks opgeslagen: ", racks_data)

func handle_shelves(data):
	shelves_data = data
	print("Shelves opgeslagen: ", shelves_data)

func handle_compartments(data):
	compartments_data = data
	print("Compartments opgeslagen: ", compartments_data)

func handle_items(data):
	items_data = data
	print("Items opgeslagen: ", items_data)
	print("Items ontvangen: ", data)
