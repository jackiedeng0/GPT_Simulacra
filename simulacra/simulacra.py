import random
import requests
import json

MAP_SIZE_X = 14
MAP_SIZE_Y = 8
TOTAL_TURNS = 2
INITIAL_PROMPT = "Pretend you are in a room surrounded by void. What would you do? (One Sentence)"
EXPORT_FILENAME = "simulation.export.json"

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

# world_context["objects"] = []

# API Setup
API_ENDPOINT = "https://api.openai.com/v1/chat/completions"
api_key_f = open("api.key", "r")
API_KEY = api_key_f.read()
api_key_f.close()
api_headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer " + API_KEY,
}


def make_api_call(prompt):
    # Makes ChatGPT API Call

    # Set up API_payload
    api_payload = {
        "model": "gpt-3.5-turbo",
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ],
        "temperature": 0.7,
        "max_tokens": 70
    }

    response = requests.post(
        API_ENDPOINT, headers=api_headers, json=api_payload)

    if response.status_code == 200:
        response_data = response.json()
        if "choices" in response_data.keys():
            return response_data["choices"][0]["message"]["content"]

    return None


# Simulation Loop
turn_history = []
# Initial Prompt
current_prompt = INITIAL_PROMPT
last_response = ""
print("Simulation in progress...")
for turn in range(TOTAL_TURNS):

    print("Starting turn", turn, "...")

    current_turn = {}
    current_turn["agents"] = {}

    # Call API
    last_response = make_api_call(current_prompt)
    if last_response == None:
        print("API Call Failed")
        break

    # Record details of turn
    current_turn["agents"][world_context["agents"][0]["name"]] = {
        "prompt": current_prompt,
        "type": "text_and_action",
        "text": last_response,
        "action": "move",
        "action_location":
            {
                "x": random.randint(0, MAP_SIZE_X-1),
                "y": random.randint(0, MAP_SIZE_Y-1)
            }
    }
    # Add turn to history
    turn_history.append(current_turn)

    # Update Prompt based on Response
    current_prompt = "You just said \"" + \
        last_response + "\". You succeeded. What's next? (One Sentence)"

# Export world to file
print("Simulation Complete. Recording...")
world_context["total_turns"] = TOTAL_TURNS
world_context["turns"] = turn_history
export_f = open(EXPORT_FILENAME, "w")
export_f.write(json.dumps(world_context))
export_f.close()

print("Record Stored.")
