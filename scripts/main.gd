extends Node2D

var agents = Array()
var turn_in_progress = false
var _temp_turn_in_progress = false
var api_key = ""
var api_headers = ["Content-Type: application/json"]
var api_endpoint = "https://api.openai.com/v1/chat/completions"
var initial_prompt = "Pretend you are stuck in a dark room. What's your first instinct?"
var last_response = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create agents from simulation export
	var simulation_file = FileAccess.open("res://simulacra/simulation.export", FileAccess.READ)
	var simulation_json = JSON.parse_string(simulation_file.get_as_text())

	var agent_scene = preload("res://scenes/agent.tscn")
	for agent in simulation_json["agents"]:
		var agent_instance = agent_scene.instantiate()
		agent_instance.init_position(Vector2i(agent["start_pos"]["x"], agent["start_pos"]["y"]))
		agent_instance.display_name = agent["name"]
		agents.append(agent_instance)
		add_child(agent_instance)
	# Set up API calls, load key
	var key_file = FileAccess.open("res://simulacra/api.key", FileAccess.READ)
	api_key = key_file.get_as_text()
	api_headers.append("Authorization: Bearer " + api_key)
	$HTTPRequest.request_completed.connect(_on_request_completed)

func _input(event):
	# Random Range Cell-based Movement
	if event.is_action_pressed("do_next") and not turn_in_progress:
		for agent in agents:
			# Movement
			agent.approach_cell(Vector2i(randi() % 14, randi() % 8 + 1))
		# Initiate API call
		var prompt = ""
		if (last_response == ""):
			prompt = initial_prompt
		else:
			prompt = "You just said \'" + last_response + "\'. You succeed. What do you do next?"

		var body = "{\"model\": \"gpt-3.5-turbo\",
			\"messages\": [{\"role\": \"user\", \"content\": \"" + prompt + "\"}],
			\"temperature\": 0.7,
			\"max_tokens\": 70
			}"
		$HTTPRequest.request(api_endpoint, api_headers, HTTPClient.METHOD_POST, body)
		turn_in_progress = true


func _on_request_completed(result, response_code, headers, body):
		var json = JSON.parse_string(body.get_string_from_utf8())
		print(json)
		if (json.has("choices")):
			last_response = json["choices"][0]["message"]["content"]
		$TextBox/TextOutput.text = last_response

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check whether each agent has finished their turn. Use a temporary
	# variable to avoid confusing _input() when multithreaded.
	_temp_turn_in_progress = false
	for agent in agents:
		if agent.turn_in_progress == true:
			_temp_turn_in_progress = true
			break
	turn_in_progress = _temp_turn_in_progress
	pass
