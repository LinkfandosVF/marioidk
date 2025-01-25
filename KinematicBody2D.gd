extends CharacterBody2D

const speed = 350.0
const jump_power = -2000.0
const acc = 50
const friction = 70
const gravity = 100
const rodeospeed = 300
var timebetweenwalljumps = 0.7

const walljumppushback = 800
const wallslidegravity = 200
var canmove = true
var iswallsliding = false
var doingrodeo = false

@onready var animated_sprite = $AnimatedSprite

func _ready():
	animated_sprite.play("idle")

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _physics_process(delta):
	var input_dir: Vector2 = input()
	
	if input_dir != Vector2.ZERO:
		accelerate(input_dir)
	else:
		add_friction()
	player_movement()
	jump()
	wallslide(delta)
	rodeo(delta)
func player_movement():
	if canmove:
		if Input.is_action_pressed("ui_left"):
			$AnimatedSprite.flip_h = true
			animated_sprite.play("walk")
		elif Input.is_action_pressed("ui_right"):
			$AnimatedSprite.flip_h = false
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
		move_and_slide()
	else:
		pass


func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acc)
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir = input_dir.normalized()
	return input_dir

func jump():
	velocity.y += gravity
	if Input.is_action_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = jump_power
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_wall() and Input.is_action_pressed("ui_right") and !is_on_floor():
			velocity.y = jump_power
			velocity.x = -walljumppushback
			wait(timebetweenwalljumps)
		if is_on_wall() and Input.is_action_pressed("ui_left") and !is_on_floor():
			wait(0.5)
			velocity.y = jump_power
			velocity.x = walljumppushback
			wait(0.5)
			wait(timebetweenwalljumps)

func wallslide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			iswallsliding = true
		else:
			iswallsliding = false
	else:
		iswallsliding = false
	
	if iswallsliding:
		velocity.y += (wallslidegravity * delta)
		velocity.y = min(velocity.y, wallslidegravity)

func rodeo(delta): #Note: when the sprite will be done DO A BAREL ROLL 
	if not is_on_wall() and !is_on_floor():
		if Input.is_action_just_pressed("rodeo"):
			wait(0.8)
			velocity.y = 0
			velocity.x = 0
			canmove = true
			doingrodeo = true
	elif is_on_floor():
				doingrodeo = false
	if doingrodeo:
		velocity.y += (rodeospeed * delta * 20)
		if Input.is_action_just_pressed("ui_accept"):
			if !$AnimatedSprite.flip_h:
				velocity.y = 0
				velocity.x = speed * 10
			elif $AnimatedSprite.flip_h:
				velocity.y = 0
				velocity.x = -speed * 10
			doingrodeo = false
			canmove = true
