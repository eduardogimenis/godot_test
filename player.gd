extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -350.0
const GRAVITY = 1200.0

enum STATE {IDLE, WALK, JUMP, FALL, ATTACK}
var current_state : STATE

@onready var dust = preload("res://dust.tscn")
@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $AnimatedSprite2D

func _ready() -> void:
	_set_state(STATE.IDLE)
	
func _set_state(new_state: STATE) -> void:
	if current_state == new_state:
		return
	
	_exit_state()
	current_state = new_state
	_enter_state()

func _enter_state() -> void:
	match current_state:
		STATE.IDLE: # Enter IDLE state logic
			$AnimatedSprite2D.play("idle")
		STATE.WALK: # Enter WALK state logic
			$AnimatedSprite2D.play("walk")
		STATE.JUMP: # Enter JUMP state logic
			velocity.y = JUMP_VELOCITY
			$AnimatedSprite2D.play("jump")
		STATE.FALL: # Enter FALL state logic
			$AnimatedSprite2D.play("fall")
		STATE.ATTACK: # Enter ATTACK state logic
			velocity.x = 0
			$AnimatedSprite2D.play("attack")

func _update_state(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("ui_left", "ui_right")
	match current_state:
		STATE.IDLE: # Update IDLE state logic
			if Input.is_action_just_pressed("attack"):
				_set_state(STATE.ATTACK)
			elif direction: # If left or right is pressed, start walking
				_set_state(STATE.WALK)
			elif !is_on_floor(): # if not on floor, fall down
				_set_state(STATE.FALL)
			elif Input.is_action_just_pressed("ui_accept"):
				_set_state(STATE.JUMP) # if the jump button is pressed, then jump
			
		STATE.WALK: # Update WALK state logic
			if Input.is_action_just_pressed("attack"):
				_set_state(STATE.ATTACK)
			velocity.x = direction * SPEED # Set the move direction
			if velocity.x > 0: # Set Sprite direction
				sprite.flip_h = false
			elif velocity.x < 0:
				sprite.flip_h = true
				
			if !is_on_floor(): # if not on floor, fall down
				_set_state(STATE.FALL)
			elif Input.is_action_just_pressed("jump"):
				_set_state(STATE.JUMP) # if jump is pressed, jump
			elif velocity.x == 0: # if standing still, then set idle
				_set_state(STATE.IDLE)
				
			move_and_slide()
			
		STATE.JUMP: # Update JUMP state logic
			if Input.is_action_just_pressed("attack"):
				_set_state(STATE.ATTACK)
			if Input.is_action_just_released("jump") and velocity.y < 0:
				velocity.y = JUMP_VELOCITY / 2
			velocity.x = direction * SPEED # Set the move direction
			if velocity.x > 0: # Set Sprite direction
				sprite.flip_h = false
			elif velocity.x < 0:
				sprite.flip_h = true
				
			if !is_on_floor(): # if in the air, apply gravity
				velocity.y += GRAVITY * delta
				if velocity.y > 0: # after max height, change from JUMP to FALL
					_set_state(STATE.FALL)
				
			move_and_slide()
			
		STATE.FALL: # Update FALL state logic
			if Input.is_action_just_pressed("attack"):
				_set_state(STATE.ATTACK)
			velocity.x = direction * SPEED # Set the move direction
			if velocity.x > 0: # Set Sprite direction
				sprite.flip_h = false
			elif velocity.x < 0:
				sprite.flip_h = true
				
			if is_on_floor(): # If the ground is reached, change back to idle
				_set_state(STATE.IDLE)
			else: # if still in the air, apply gravity
				velocity.y += GRAVITY * delta
				
			move_and_slide()

		STATE.ATTACK: # Update ATTACK state logic
			velocity.y += GRAVITY * delta # Apply gravity
			if !is_on_floor(): # Allow horizontal movement while attacking in air
				velocity.x = direction * SPEED 
				if velocity.x > 0: # Set Sprite direction
					sprite.flip_h = false
				elif velocity.x < 0:
					sprite.flip_h = true
			elif is_on_floor():
				velocity.x = 0
			if $AnimatedSprite2D.is_playing() == false:
				if is_on_floor():
					_set_state(STATE.IDLE)
				else:
					_set_state(STATE.FALL)

			move_and_slide()

func _physics_process(delta: float) -> void:
	_update_state(delta)

func _exit_state() -> void:
	match current_state:
		STATE.IDLE: # Exit IDLE state logic
			pass
			
		STATE.WALK: # Exit WALK state logic
			pass
			
		STATE.JUMP: # Exit JUMP state logic
			pass
			
		STATE.FALL: # Exit FALL state logic
			# creates a landing animation instance
			var dust_instance = dust.instantiate()
			dust_instance.global_position = $landing_spot.global_position
			get_parent().add_child(dust_instance)
		STATE.ATTACK: # Exit ATTACK state logic
			pass

signal entered
signal exited
func _on_area_2d_area_entered(area):
	emit_signal("entered")
func _on_area_2d_area_exited(area):
	emit_signal("exited")
