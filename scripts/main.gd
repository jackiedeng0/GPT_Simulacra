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

func _input(event):
	# Random Range Cell-based Movement
	if event.is_action_pressed("do_next") and not turn_in_progress:
		for agent in agents:
			agent.approach_cell(Vector2i(randi() % 14, randi() % 8 + 1))
		turn_in_progress = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check whether each agent has finished their turn. Use a temporary
	# variable to avoid confusing _input() when multithreaded.
	_temp_turn_in_progress = false
	for agent in agents:
		if agent.turn_in_progress == true:
			_temp_turn_in_progress = true
	turn_in_progress = _temp_turn_in_progress
	pass
