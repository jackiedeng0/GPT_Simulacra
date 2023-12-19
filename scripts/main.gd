extends Node2D

var agents = Array()
var turn_in_progress = false
var _temp_turn_in_progress = false
var total_turns = 0
var turn = 0
var last_response = ""
var simulation_json

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create agents from simulation export
	var simulation_file = FileAccess.open("res://simulacra/simulation.export.json", FileAccess.READ)
	simulation_json = JSON.parse_string(simulation_file.get_as_text())
	total_turns = simulation_json["total_turns"]

	var agent_scene = preload("res://scenes/agent.tscn")
	for agent in simulation_json["agents"]:
		var agent_instance = agent_scene.instantiate()
		agent_instance.init_position(Vector2i(agent["start_pos"]["x"], agent["start_pos"]["y"]))
		agent_instance.display_name = agent["name"]
		agents.append(agent_instance)
		add_child(agent_instance)

func _input(event):
	if event.is_action_pressed("do_next") and not turn_in_progress:
		# If last turn is over, do nothing
		if turn >= total_turns:
			return
		# Retrieve data about turn
		for agent in agents:
			# Extract the agent's turn information
			var agent_turn_json = simulation_json["turns"][turn]["agents"][agent.display_name]
			if agent_turn_json["type"] == "text_and_action":
				$TextBox/TextOutput.text = agent_turn_json["text"]
				if agent_turn_json["action"] == "move":
					agent.approach_cell(Vector2i(agent_turn_json["action_location"]["x"],
						agent_turn_json["action_location"]["y"]))
		turn += 1
		turn_in_progress = true

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
