extends CharacterBody2D

enum DIRECTION {LEFT, RIGHT, UP, DOWN}

const GRID_SIZE = 16
const SPEED = GRID_SIZE * 4
var real_dir = DIRECTION.DOWN
var finished_last_move = true
var next_position = Vector2()

func _ready():
	next_position.x = position.x
	next_position.y = position.y
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	player_movement(delta)

func player_movement(delta):

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
