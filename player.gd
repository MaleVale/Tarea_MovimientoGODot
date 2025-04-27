extends CharacterBody2D

const GRAVITY = 1200.0
const SPEED = 200.0
const ACCELERATION = 800.0
const FRICTION = 600.0
const JUMP_FORCE = -400.0
const MAX_JUMPS = 2
const DASH_SPEED = 500.0
const DASH_DURATION = 0.2

var jumps = 0
var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector2.ZERO

func _physics_process(delta):
	var input_direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	# Movimiento lateral normal
	if not is_dashing:
		if input_direction != 0:
			velocity.x = move_toward(velocity.x, input_direction * SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Saltos
	if is_on_floor():
		jumps = 0

	if Input.is_action_just_pressed("jump") and jumps < MAX_JUMPS:
		velocity.y = JUMP_FORCE
		jumps += 1
	elif Input.is_action_just_released("jump") and velocity.y < JUMP_FORCE / 2:
		velocity.y = JUMP_FORCE / 2

	# Dash
	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_direction = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		).normalized()
		
		# Si no hay input, dash hacia donde estábamos moviéndonos o hacia la derecha
		if dash_direction == Vector2.ZERO:
			dash_direction = Vector2(sign(velocity.x) if velocity.x != 0 else 1, 0)

	if is_dashing:
		velocity = dash_direction * DASH_SPEED
		dash_timer -= delta

		# Rebote contra paredes
		if is_on_wall():
			dash_direction.x = -dash_direction.x
			velocity.x = dash_direction.x * DASH_SPEED
		
		if dash_timer <= 0:
			is_dashing = false

	# Gravedad normal
	if not is_dashing:
		velocity.y += GRAVITY * delta

	move_and_slide()
