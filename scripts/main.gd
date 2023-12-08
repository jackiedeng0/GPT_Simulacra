extends Node2D

var agents = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create an agent
	var agent_scene = preload("res://scenes/agent.tscn")
	var agent_instance = agent_scene.instantiate()
	agent_instance.init_position(Vector2i(randi() % 14, randi() % 8 + 1))
	agents.append(agent_instance)
	add_child(agent_instance)
	var agent_instance2 = agent_scene.instantiate()
	agent_instance2.init_position(Vector2i(randi() % 14, randi() % 8 + 1))
	agents.append(agent_instance2)
	add_child(agent_instance2)

func _input(event):
	# Random Range Cell-based Movement
	if event.is_action_pressed("do_next"):
		for agent in agents:
			agent.approach_cell(Vector2i(randi() % 14, randi() % 8 + 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
