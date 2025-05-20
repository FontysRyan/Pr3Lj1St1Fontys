extends Node

# Dit script beheert data voor een warehouse management systeem
# Het communiceert met een externe API en beheert verschillende datasets
# voor zones, racks, compartments, shelves, products en hun locaties

var latest_data
var current_table: String = ""

# --- Data storage ---
# Arrays voor het opslaan van verschillende datatypen uit de database
var zones_data: Array = []       # Magazijngebieden
var racks_data: Array = []       # Stellingen in het magazijn
var shelves_data: Array = []     # Planken binnen compartments
var compartments_data: Array = [] # Compartimenten binnen stellingen
var products_data: Array = []    # Productgegevens
var product_locations_data: Array = [] # Link tussen producten en hun locatie

# Statistieken over de magazijnstructuur
#var rack_amount           # Totaal aantal stellingen
#var compartment_amount    # Aantal compartments per rack
#var shelf_amount          # Aantal shelves per compartment

# Vlaggen om bij te houden of data is geladen
var shelves_loaded = false
var products_loaded = false

# Wordt uitgevoerd bij het starten van de node
func _ready() -> void:	
	# Uitgecommentarieerde code voor het aanmaken van test-warehouses en zones
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
	
	# Laad eerst alle bestaande data uit de database
	await load_all_data_from_db()
	
	# --- Uitgecommentarieerde functies om de database met testdata te vullen ---
	
	#--- Populeer de database met X hoeveelheid racks ---
	#insert_x_times_racks(43)
	
	#--- Populeer de database met X compartments per rack ---
	#insert_x_times_compartments(50)
	
	#--- Populeer de shelves database emt x shelfs per compartment ---
	#insert_shelves_from_compartments()
	
	#--- Maak X hoeveelheid producten ---
	#insert_x_times_products(2500)
	
	#--- geef alle producten een locatie en link dit aan een product
	#generate_and_send_product_locations(products_data, shelves_data, 2500)
	
	#--- Bereken hoeveel racks er zijn ---
	Global.rack_amount = get_rack_amount()
	print(Global.rack_amount)
	
	#--- Bereken hoeveel compartments per rack er zijn ---
	Global.compartment_amount = get_compartment_amount()
	print(Global.compartment_amount)
	
	#--- Bereken hoeveel shelves per rack er zijn ---
	Global.shelf_amount = get_shelf_amount()
	print(Global.shelf_amount)
	
	#var products = find_product_by_location("A", 1, 1)
	
#func _on_data_received(data):
	#print("Received data: " + data)
	#latest_data = data

# --- Queue-systeem voor het versturen van rack data ---
var rack_queue: Array = []       # Wachtrij met racks om te versturen
var current_index: int = 0       # Huidige positie in de wachtrij
var sending: bool = false        # Is er momenteel een versturing bezig?

# Berekent het totaal aantal racks in het systeem
func get_rack_amount():
	return len(racks_data)
	
# Berekent het gemiddeld aantal compartments per rack
func get_compartment_amount():
	return len(compartments_data) / len(racks_data)
	
# Berekent het gemiddeld aantal shelves per compartment
func get_shelf_amount():
	return len(shelves_data) / len(compartments_data)
	
# --- Laadt alle data van alle tabellen uit de MySQL database ---
func load_all_data_from_db():
	# Haal alle data op voor elke tabel met korte pauzes tussen de verzoeken
	current_table = "zones"
	get_data("zones")
	await get_tree().create_timer(1.2).timeout
		
	current_table = "racks"
	get_data("racks")
	await get_tree().create_timer(1.2).timeout
	
	current_table = "shelves"
	get_data("shelves")
	await get_tree().create_timer(1.2).timeout

	current_table = "compartments"
	get_data("compartments")
	await get_tree().create_timer(1.2).timeout

	current_table = "products"
	get_data("products")
	await get_tree().create_timer(1.2).timeout

	current_table = "product_locations"
	get_data("product_locations")
	await get_tree().create_timer(1.2).timeout


# --- Maakt x aantal racks aan en verstuurt ze naar de database ---
func insert_x_times_racks(x: int) -> void:
	rack_queue.clear()
	# Maak x aantal racks en voeg ze toe aan de wachtrij
	for i in range(x):
		rack_queue.append({
			"zone_id": 1,
			"rack_number": str(i + 1),
			"capacity": 1
		})
	current_index = 0
	sending = true
	_send_next_rack()

# --- Verstuurt het volgende rack in de wachtrij naar de database ---
func _send_next_rack() -> void:
	if current_index < rack_queue.size():
		var data = rack_queue[current_index]
		post_data("http://192.168.133.123:5000/insert/racks", data)
	else:
		print("All racks inserted.")
		sending = false


# --- Queue-systeem voor het versturen van compartment data ---
var compartment_queue: Array = []      # Wachtrij met compartments om te versturen
var current_compartment_index: int = 0  # Huidige positie in de wachtrij
var sending_compartments: bool = false  # Is er momenteel een versturing bezig?

# --- Maakt x aantal compartments per rack aan en verstuurt ze naar de database ---
func insert_x_times_compartments(x: int) -> void:
	compartment_queue.clear()
	# Maak voor 86 racks elk x compartments aan
	for i in range(86):
		for n in range(x):
			compartment_queue.append({
				"rack_id": i + 1,  # rack ID
				"compartment_number": n + 1  # compartment nummer binnen het rack
			})
	current_compartment_index = 0
	sending_compartments = true
	_send_next_compartment()

# --- Verstuurt het volgende compartment in de wachtrij naar de database ---
func _send_next_compartment() -> void:
	if current_compartment_index < compartment_queue.size():
		var data = compartment_queue[current_compartment_index]
		print("Sending compartment ", current_compartment_index + 1, ": ", data)
		post_data("http://192.168.133.123:5000/insert/compartments", data)
	else:
		print("All compartments inserted.")
		sending_compartments = false

# --- Queue-systeem voor het versturen van shelf data ---
var shelf_queue: Array = []        # Wachtrij met shelves om te versturen
var current_shelf_index: int = 0    # Huidige positie in de wachtrij 
var sending_shelves: bool = false   # Is er momenteel een versturing bezig?

# --- Maakt voor elk compartment een shelf aan en verstuurt ze naar de database ---
func insert_shelves_from_compartments() -> void:
	if compartments_data.is_empty():
		print("Geen compartimenten geladen, eerst load_all_data_from_db() uitvoeren.")
		return

	shelf_queue.clear()
	# Voor elk compartment, maak een corresponderende shelf aan
	for compartment in compartments_data:
		var shelf_data = {
			"zone_id": 1,  # Pas aan indien nodig of haal het uit rack/compartiment data
			"rack_id": compartment["rack_id"],
			"compartment_id": compartment["compartment_id"],
			"shelf_number": compartment["compartment_number"],  # EÃ©n shelf per compartment
			"max_weight": 57  # Maximaal gewicht in kg
		}
		shelf_queue.append(shelf_data)

	current_shelf_index = 0
	sending_shelves = true
	_send_next_shelf()

# --- Verstuurt de volgende shelf in de wachtrij naar de database ---
func _send_next_shelf() -> void:
	if current_shelf_index < shelf_queue.size():
		var data = shelf_queue[current_shelf_index]
		print("Sending shelf ", current_shelf_index + 1, ": ", data)
		post_data("http://192.168.133.123:5000/insert/shelves", data)
	else:
		print("All shelves inserted.")
		sending_shelves = false

# --- Queue-systeem voor het versturen van product data ---
var product_queue: Array = []         # Wachtrij met producten om te versturen
var current_product_index: int = 0     # Huidige positie in de wachtrij
var sending_products: bool = false     # Is er momenteel een versturing bezig?

# --- Maakt x aantal producten aan en verstuurt ze naar de database ---
func insert_x_times_products(x: int) -> void:
	product_queue.clear()
	# Maak x aantal producten met willekeurige eigenschappen
	for i in range(x):
		var random_index = randi() % product_names.size()
		var product_name = product_names[random_index]
		var product_description = product_descriptions[random_index]
		var product = {
			"sku": "SKU" + str(i + 1),  # Unieke product code
			"name": product_name,       # Willekeurige naam uit de lijst
			"description": product_description,  # Bijbehorende beschrijving
			"weight": randf_range(0.5, 57),  # Willekeurig gewicht tussen 0.5 en 57 kg
			"barcode": "BAR" + str(100000 + i)  # Unieke barcode
		}
		product_queue.append(product)

	current_product_index = 0
	sending_products = true
	_send_next_product()
	
# --- Verstuurt het volgende product in de wachtrij naar de database ---
func _send_next_product() -> void:
	if current_product_index < product_queue.size():
		var data = product_queue[current_product_index]
		print("Sending product ", current_product_index + 1, ": ", data)
		post_data("http://192.168.133.123:5000/insert/products", data)
	else:
		print("All products inserted.")
		sending_products = false

# --- Queue-systeem voor het versturen van product locatie data ---
var product_location_queue: Array = []    # Wachtrij met product locaties om te versturen
var current_location_index: int = 0       # Huidige positie in de wachtrij
var sending_locations: bool = false       # Is er momenteel een versturing bezig?

# --- Genereert toewijzingen tussen producten en shelves en verstuurt ze naar de database ---
func generate_and_send_product_locations(products: Array, shelves: Array, max_locations: int) -> void:
	if products.size() == 0 or shelves.size() == 0:
		print("FOUT: Geen producten of shelves beschikbaar.")
		return

	product_location_queue.clear()
	var statuses = ["in_stock", "reserved", "damaged"]  # Mogelijke voorraadstatussen

	# Maak een willekeurige selectie van shelves
	var shuffled_shelves = shelves.duplicate()
	shuffled_shelves.shuffle()
	var selected_shelves = shuffled_shelves.slice(0, min(max_locations, shuffled_shelves.size()))

	# Ken aan elke geselecteerde shelf een product toe
	for shelf in selected_shelves:
		var product = products[randi() % products.size()]  # Willekeurig product
		var location = {
			"product_id": product["product_id"],
			"zone_id": shelf["zone_id"],
			"shelf_id": shelf["shelf_id"],
			"quantity": randi() % 50 + 1,  # Willekeurige hoeveelheid tussen 1-50
			"batch_number": "BATCH-" + str(randi() % 10000).pad_zeros(4),  # Batch nummer
			"date_received": "2024-" + str(randi() % 12 + 1).pad_zeros(2) + "-" + str(randi() % 28 + 1).pad_zeros(2),  # Willekeurige datum in 2024
			"status": "available"  # Standaard status
		}
		product_location_queue.append(location)

	current_location_index = 0
	sending_locations = true
	_send_next_product_location()

# --- Verstuurt de volgende product locatie in de wachtrij naar de database ---
func _send_next_product_location() -> void:
	if current_location_index < product_location_queue.size():
		var data = product_location_queue[current_location_index]
		print("Verstuur locatie ", current_location_index + 1, ": ", data)
		post_data("http://192.168.133.123:5000/insert/product_locations", data)
	else:
		print("Alle productlocaties verzonden.")
		sending_locations = false
		
# --- Stuurt data naar de API via een POST verzoek ---
func post_data(url: String, data: Dictionary) -> void:
	var http = $HTTPRequest
	var headers = ["Content-Type: application/json"]
	var json_data = JSON.stringify(data)
	
	var result = http.request(url, PackedStringArray(headers), HTTPClient.METHOD_POST, json_data)
	if result != OK:
		print("POST request failed to start: ", result)

# --- Haalt data op van de API via een GET verzoek ---
func get_data(table_name: String) -> void:
	current_table = table_name  # Bewaar de huidige tabel context
	var http = $HTTPRequest
	var url = "http://192.168.133.123:5000/select/" + table_name
	
	var headers = PackedStringArray()
	var result = http.request(url, headers, HTTPClient.METHOD_GET)
	
	if result != OK:
		print("GET request failed: ", result)
	else:
		print("GET request sent successfully for table: ", table_name)

# --- Callback functie die wordt aangeroepen na voltooiing van een HTTP verzoek ---
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var text = body.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		print("Kon JSON niet parsen.")
		return

	# Verwerk de ontvangen data op basis van de huidige tabel context
	if typeof(parsed) == TYPE_ARRAY:
		match current_table:
			"zones":
				zones_data = parsed
				print("Zones opgeslagen: aantal =", zones_data.size())
			"racks":
				racks_data = parsed
				print("Racks opgeslagen: aantal =", racks_data.size())
			"shelves":
				shelves_data = parsed
				print("Shelves opgeslagen: aantal =", shelves_data.size())
				shelves_loaded = true
				#if products_loaded:
					#generate_and_send_product_locations(products_data, shelves_data, 2500)
			"compartments":
				compartments_data = parsed
				print("Compartments opgeslagen: aantal =", compartments_data.size())
			"products":
				products_data = parsed
				print("Products opgeslagen: aantal =", products_data.size())
				products_loaded = true
				#if shelves_loaded:
					#generate_and_send_product_locations(products_data, shelves_data, 2500)
			"product_locations":
				product_locations_data = parsed
				print("Product-locaties geladen: aantal =", product_locations_data.size())
			_:
				print("Onbekende tabel: ", current_table)

	# Verwerk de volgende items in de verschillende wachtrijen indien nodig
	if sending:
		current_index += 1
		_send_next_rack()
	elif sending_compartments:
		current_compartment_index += 1
		_send_next_compartment()
	elif sending_shelves:
		current_shelf_index += 1
		_send_next_shelf()
	elif sending_products:
		current_product_index += 1
		_send_next_product()
	elif sending_locations:
		current_location_index += 1
		_send_next_product_location()
		
# --- Data Handler Functies ---
# Deze functies verwerken de ontvangen data per datataype
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
	#print("Compartments opgeslagen: ", compartments_data)

func handle_items(data):
	products_data = data
	#print("Items opgeslagen: ", products_data)
	#print("Items ontvangen: ", data)


# --- Product testdata ---
# Lijst met realistische productnamen voor testdata
var product_names = [
	"LED Lamp", "Bureau", "Luidspreker", "Koffiezetapparaat", "Monitor 24 inch", "USB-C Kabel",
	"HDMI Adapter", "Smartphone Houder", "Laptop Stand", "Toetsenbord", "Muis", "Powerbank",
	"Oplader", "Waterfles", "Thermoskan", "Ventilator", "Verlengsnoer", "Notitieboek",
	"Plakbandhouder", "Printerpapier", "Etiketrollen", "Batterijen AA", "Batterijen AAA",
	"Zaklamp", "Stekkerdoos", "Wandklok", "Rekenmachine", "Draadloze Lader", "Tablet Case",
	"Fietslicht", "Gereedschapsset", "Schroevendraaierset", "Boormachine", "Opbergdoos",
	"Plastic Kratten", "Handschoenen", "Veiligheidsbril", "Gehoorbescherming", "Plaknotities",
	"USB Stick 32GB", "USB Stick 64GB", "SD Kaart 128GB", "SSD 1TB", "Harde Schijf 2TB",
	"Ethernet Kabel", "WiFi Router", "Netwerkswitch", "Beveiligingscamera", "Rookmelder",
	"Thermometer", "Digitale Weegschaal", "Labelprinter", "Kartonmessen", "Afplaktape",
	"Schuurpapier", "Verfspuit", "Verfroller", "Schroeven Set", "Spijkerset", "Verstelbare Moersleutel",
	"Vouwladder", "Rubberen Hamer", "Magnetron", "Broodrooster", "Stofzuiger", "Stoomreiniger",
	"Kledinghanger", "Kledingrek", "Wasmand", "Strijkplank", "Strijkijzer", "Emmer 10L", "Spons",
	"Dweil", "Vuilniszakken", "Afwasmiddel", "Allesreiniger", "Keukenrol", "Papieren Bekers",
	"Plastic Bestek", "Papieren Borden", "Handdoeken", "Zeepdispenser", "Papierversnipperaar",
	"Archiefkast", "Ladekast", "Vloermat", "Kantoorstoel", "Bureau Lamp", "Fotolijst", "Witte Verf",
	"Zwarte Verf", "Grijze Verf", "Multitool", "Tangenset", "Meetlint", "Waterpas", "Handschoenenset"
]

# Lijst met bijbehorende productbeschrijvingen voor testdata
var product_descriptions = [
	"Energiezuinige LED-lamp met een levensduur van 25.000 uur.",
	"Modern houten bureau met kabelmanagement systeem.",
	"Compacte luidspreker met krachtig geluid en bluetooth-functionaliteit.",
	"Volautomatisch koffiezetapparaat met timer en warmhoudplaat.",
	"Full HD monitor van 24 inch met ingebouwde luidsprekers.",
	"Flexibele USB-C kabel van 1 meter met snelle data-overdracht.",
	"HDMI-adapter voor aansluiting op laptops en tv-schermen.",
	"Verstelbare smartphone houder met antislip design.",
	"Ergonomische laptopstandaard van aluminium.",
	"Draadloos toetsenbord met stille toetsen en lange batterijduur.",
	"Precisie muis met 5 programmeerbare knoppen.",
	"10.000mAh powerbank geschikt voor smartphones en tablets.",
	"Snellader met twee USB-poorten en ingebouwde beveiliging.",
	"Herbruikbare waterfles van 750 ml, BPA-vrij.",
	"Dubbelwandige thermoskan die 12 uur warm houdt.",
	"Bureauventilator met drie snelheidsstanden.",
	"Stevige verlengsnoer van 5 meter met overspanningsbeveiliging.",
	"Hardcover notitieboek met gelinieerde pagina's.",
	"Zware plakbandhouder met antislip onderzijde.",
	"Wit A4 printerpapier van hoge kwaliteit (500 vel).",
	"Rollen voor thermische etiketten, geschikt voor labelprinters.",
	"Set van 20 AA-batterijen met lange levensduur.",
	"Set van 20 AAA-batterijen voor afstandsbedieningen en speelgoed.",
	"Robuuste zaklamp met LED en zoomfunctie.",
	"Stekkerdoos met zes aansluitingen en aan/uit schakelaar.",
	"Moderne wandklok met stil uurwerk.",
	"Basismodel rekenmachine met groot display.",
	"Snelle draadloze lader voor Qi-compatibele apparaten.",
	"Waterdichte tablet case met standaardfunctie.",
	"Set voor- en achterlicht voor fiets, USB-oplaadbaar.",
	"Compleet gereedschapsset in stevige koffer.",
	"Set schroevendraaiers met magnetische punt.",
	"Krachtige accuboormachine met twee accu's.",
	"Transparante opbergdoos van 60 liter met deksel.",
	"Gestapelde kunststof kratten voor transport en opslag.",
	"Universele werkhandschoenen met goede grip.",
	"Veiligheidsbril met krasbestendige coating.",
	"Oorkappen voor geluidsreductie tot 30dB.",
	"Sticky notes in vijf kleuren, 100 vel per kleur.",
	"USB-stick met 32GB opslagcapaciteit en metalen behuizing.",
	"64GB USB-stick met USB 3.0 snelheid.",
	"128GB SD-kaart voor camera's en drones.",
	"Interne SSD van 1TB met leessnelheid tot 500MB/s.",
	"2TB externe harde schijf met USB 3.1 aansluiting.",
	"Cat6 ethernet kabel van 2 meter, afgeschermd.",
	"Dual-band WiFi-router met vier antennes.",
	"8-poorts netwerkswitch voor kleine netwerken.",
	"Full HD beveiligingscamera met bewegingsdetectie.",
	"Rookmelder met 10 jaar batterijduur.",
	"Digitale thermometer met snelle meting.",
	"Keukenweegschaal met LCD-scherm en tarrafunctie.",
	"Labelprinter met draadloze verbinding.",
	"Set van 10 kartonmessen met inklapbaar mes.",
	"Afplaktape van 25 mm voor schilderklussen.",
	"Schuurpapier in diverse korrelgroottes.",
	"Professionele verfspuit voor gelijkmatige dekking.",
	"Verfroller met anti-spat technologie.",
	"Set van 100 schroeven in verschillende maten.",
	"Set van 150 spijkers in opbergdoosje.",
	"Verstelbare moersleutel van 200 mm.",
	"Inklapbare aluminium vouwladder, 4 meter.",
	"Rubberen hamer voor kwetsbare oppervlakken.",
	"Compacte magnetron met 20 liter inhoud.",
	"Roestvrijstalen broodrooster met 7 standen.",
	"Stofzuiger met HEPA-filter en 9 meter snoer.",
	"Stoomreiniger voor vloeren en tegels.",
	"Metalen kledinghangers, set van 20 stuks.",
	"Verstelbaar kledingrek met wielen.",
	"Wasmand van ademend materiaal, 60 liter.",
	"Inklapbare strijkplank met verstelbare hoogte.",
	"Stoomstrijkijzer met anti-kalksysteem.",
	"Kunststof emmer van 10 liter met maatverdeling.",
	"Multifunctionele spons voor auto en huis.",
	"Microvezeldweil met uitschuifbare steel.",
	"Sterke vuilniszakken (60 liter, 30 stuks).",
	"Afwasmiddel met citroengeur, 1 liter fles.",
	"Allesreiniger voor vloeren en oppervlakken.",
	"Twee rollen keukenpapier, extra absorberend.",
	"Papieren bekers, 200 ml, set van 50 stuks.",
	"Wegwerp bestek, wit plastic, 24-delig.",
	"Wegwerpborden van karton, diameter 23 cm.",
	"Zachte katoenen handdoek (50x100 cm).",
	"Navulbare zeepdispenser van glas.",
	"Cross-cut papierversnipperaar voor A4 papier.",
	"Stalen archiefkast met 3 laden.",
	"Kunststof ladekast met transparante lades.",
	"Vloermat voor bureaustoel, antislip.",
	"Ergonomische kantoorstoel met lendensteun.",
	"Bureaulamp met verstelbare arm en LED-licht.",
	"Fotolijst voor A4 formaat, staand of hangend.",
	"Matwitte muurverf, 2,5 liter.",
	"Diepzwarte muurverf, 1 liter.",
	"Grijze muurverf, zijdeglans afwerking.",
	"Multitool met 14 functies, inclusief mes en zaag.",
	"Set tangen met ergonomische handgrepen.",
	"Meetlint van 5 meter met vergrendeling.",
	"Waterpas van 60 cm met magnetische strip.",
	"Set van 3 paar werkhandschoenen in verschillende maten."
]
