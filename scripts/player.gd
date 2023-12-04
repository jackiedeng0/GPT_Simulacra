extends CharacterBody2D

enum DIRECTION {LEFT, RIGHT, UP, DOWN}

const GRID_SIZE = 16
const SPEED = GRID_SIZE * 5
var real_dir = DIRECTION.DOWN
var finished_last_move = true
var next_position = Vector2()

func _ready():
	next_position.x = position.x
	next_position.y = position.y
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	click_movement(delta)

# Click Movement
func _input(event):
	if event.is_action_pressed("ui_select"):
		next_position = ((floor(get_global_mouse_position() / 16)* 16) +
			Vector2(8, -8))
		velocity = position.direction_to(next_position) * SPEED
		var angle = velocity.angle()
		print(angle)
		if (abs(angle) <= PI/4):
			real_dir = DIRECTION.RIGHT
		elif (abs(angle) > (3*PI/4)):
			real_dir = DIRECTION.LEFT
		elif (angle > 0):
			real_dir = DIRECTION.DOWN
		else:
			real_dir = DIRECTION.UP
		update_animation()

func click_movement(delta):
	if position.distance_to(next_position) < 2:
		velocity = Vector2(0, 0)
		position = next_position
		update_animation()
	move_and_slide()

# WASD Movement
func wasd_movement(delta):

	# Close enough to having finished the last movement command
	finished_last_move = position.distance_to(next_position) < 1

	if (finished_last_move):
		# Fix position in place
		position = next_position
		finished_last_move = false
		if Input.is_action_pressed("ui_right"):
			real_dir = DIRECTION.RIGHT
			velocity.x = SPEED
			velocity.y = 0
			update_animation()
			next_position = floor(Vector2(position.x + GRID_SIZE, position.y))
		elif Input.is_action_pressed("ui_left"):
			real_dir = DIRECTION.LEFT
			velocity.x = -SPEED
			velocity.y = 0
			update_animation()
			next_position = floor(Vector2(position.x - GRID_SIZE, position.y))
		elif Input.is_action_pressed("ui_down"):
			real_dir = DIRECTION.DOWN
			velocity.x = 0
			velocity.y = SPEED
			update_animation()
			next_position = floor(Vector2(position.x, position.y + GRID_SIZE))
		elif Input.is_action_pressed("ui_up"):
			real_dir = DIRECTION.UP
			velocity.x = 0
			velocity.y = -SPEED
			update_animation()
			next_position = floor(Vector2(position.x, position.y - GRID_SIZE))
		else:
			velocity.x = 0
			velocity.y = 0
			update_animation()

	move_and_slide()

func update_animation():
	var anim = $AnimatedSprite2D

	if real_dir == DIRECTION.RIGHT:
		anim.flip_h = false
		if velocity.x == 0:
			anim.play("side_idle")
		else:
			anim.play("side_walk")
	elif real_dir == DIRECTION.LEFT:
		anim.flip_h = true
		if velocity.x == 0:
			anim.play("side_idle")
		else:
			anim.play("side_walk")
	elif real_dir == DIRECTION.DOWN:
		if velocity.y == 0:
			anim.play("front_idle")
		else:
			anim.play("front_walk")
	elif real_dir == DIRECTION.UP:
		if velocity.y == 0:
			anim.play("back_idle")
		else:
			anim.play("back_walk")
