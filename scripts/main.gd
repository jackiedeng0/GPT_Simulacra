extends Node2D

const GRID_SIZE = 16
const SCALE_FACTOR = 4
const GRID_UNUSED_CELLS_ABOVE = 3
var agents = Array()
var turn_in_progress = false
var _temp_turn_in_progress = false
var total_turns = 0
var turn = 0
var last_response = ""
var simulation_json
var map_size

# Called when the node enters the scene tree for the first time.
func _ready():
	var simulation_file = FileAccess.open("res://simulacra/simulation.export.json", FileAccess.READ)
	simulation_json = JSON.parse_string(simulation_file.get_as_text())
	total_turns = simulation_json["total_turns"]
	
	# Lay out tiles for map
	map_size = Vector2i(simulation_json["map_size"]["x"], simulation_json["map_size"]["y"])
	for i in range(map_size.x):
		# 1 extra map height for character height
		for j in range(map_size.y + 1):
			# Allow height for textbox
			$TileMap.set_cell(0, Vector2i(i, j+2), 1, Vector2i(9, 23))

	# Set window size
	get_window().size = Vector2i(map_size.x, map_size.y + 3) * GRID_SIZE * SCALE_FACTOR

	# Create agents from simulation export
	var agent_scene = preload("res://scenes/agent.tscn")
	for agent in simulation_json["agents"]:
		var agent_instance = agent_scene.instantiate()
		agent_instance.init_position(Vector2i(agent["start_pos"]["x"], agent["start_pos"]["y"] + GRID_UNUSED_CELLS_ABOVE))
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
				$TextBox/TextOutput.text = agent.display_name + ": " + agent_turn_json["text"]
				if agent_turn_json["action"] == "move":
					agent.approach_cell(Vector2i(agent_turn_json["action_location"]["x"],
						agent_turn_json["action_location"]["y"] + GRID_UNUSED_CELLS_ABOVE))
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
