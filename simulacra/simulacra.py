import random
import json

# api_key = ""
# api_endpoint = ""
MAP_SIZE_X = 14
MAP_SIZE_Y = 8

# Initialize world
world_context = {"map_size":
                 {"x": MAP_SIZE_X, "y": MAP_SIZE_Y}}

world_context["agents"] = [{
    "name": "Dionysus",
    "start_pos": {
        "x": random.randint(0, MAP_SIZE_X-1),
        "y": random.randint(0, MAP_SIZE_Y-1)
    }
}]

world_context["objects"] = []

# Export world to file
export_f = open("simulation.export", "w")
export_f.write(json.dumps(world_context))
export_f.close()
