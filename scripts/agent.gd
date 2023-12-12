extends CharacterBody2D

class_name Agent

enum DIRECTION {LEFT, RIGHT, UP, DOWN}

const GRID_SIZE = 16
const GRID_OFFSET = 8
const SPEED = GRID_SIZE * 5
var real_dir = DIRECTION.DOWN
var finished_last_move = true
var current_cell = Vector2i()
var next_position = Vector2()
var turn_in_progress = false

func init_position(cell:Vector2i = Vector2i(0, 1)):
	current_cell = cell
	position = Vector2(cell * GRID_SIZE) + Vector2(GRID_OFFSET, -GRID_OFFSET)

func _ready():
	next_position.x = position.x
	next_position.y = position.y
	current_cell = Vector2i(floor(position) / GRID_SIZE)
	randomize()
	$AnimatedSprite2D.play("front_idle")

func _physics_process(_delta):
	grid_movement()

func approach_cell(next_cell):
		next_position = Vector2(next_cell * GRID_SIZE) + Vector2(GRID_OFFSET, -GRID_OFFSET)
		velocity = position.direction_to(next_position) * SPEED
		var angle = velocity.angle()
		if (abs(angle) <= PI/4):
			real_dir = DIRECTION.RIGHT
		elif (abs(angle) > (3*PI/4)):
			real_dir = DIRECTION.LEFT
		elif (angle > 0):
			real_dir = DIRECTION.DOWN
		else:
			real_dir = DIRECTION.UP
		turn_in_progress = true
		update_animation()

func grid_movement():
	if position.distance_to(next_position) < 2:
		velocity = Vector2(0, 0)
		current_cell = Vector2i(floor(position) / GRID_SIZE)
		position = next_position
		turn_in_progress = false
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
