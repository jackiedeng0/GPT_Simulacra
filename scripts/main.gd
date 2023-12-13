extends Node2D

const INITIAL_AGENTS_COUNT = 3

var agents = Array()
var turn_in_progress = false
var _temp_turn_in_progress = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create an agent
	var agent_scene = preload("res://scenes/agent.tscn")
	for i in range(INITIAL_AGENTS_COUNT):
		var agent_instance = agent_scene.instantiate()
		agent_instance.init_position(Vector2i(randi() % 14, randi() % 8 + 1))
		agents.append(agent_instance)
		add_child(agent_instance)
	# Set up API calls
	$HTTPRequest.request_completed.connect(_on_request_completed)


func _input(event):
	# Random Range Cell-based Movement
	if event.is_action_pressed("do_next") and not turn_in_progress:
		for agent in agents:
			# Movement
			agent.approach_cell(Vector2i(randi() % 14, randi() % 8 + 1))
		# Initiate API call (placeholder)
		$HTTPRequest.request("https://uselessfacts.jsph.pl/api/v2/facts/random")
		turn_in_progress = true


func _on_request_completed(result, response_code, headers, body):
		var json = JSON.parse_string(body.get_string_from_utf8())
		$TextBox/TextOutput.text = json["text"]

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
