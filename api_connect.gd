extends Node2D

var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	var url = "http://192.168.133.123:5000/select/warehouses"
	http_request.request(url)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var response = body.get_string_from_utf8()
		var data = JSON.parse_string(response)
		print("Fetched:", data)
	else:
		print("Error:", response_code)
