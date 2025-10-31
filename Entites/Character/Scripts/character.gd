extends CharacterBody2D

@export var SPEED := 60.0
const GRAVITY := 230.0
const JUMP_FORCE := 100.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var jump_queued := false
var attacking := false
var was_on_floor := false
var current_speed: float

func _ready() -> void:
	anim_sprite.connect("animation_finished", _on_animation_finished)
	current_speed = SPEED
	collision_shape_2d.disabled = true
	

func _physics_process(delta: float) -> void:
	var on_floor_now := is_on_floor()

	if not on_floor_now:
		velocity.y += GRAVITY * delta

	var direction := Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	
	if not attacking:
		velocity.x = direction * current_speed
	else:
		velocity.x = 0
		
	if abs(direction) > 0.01 and not attacking:
		anim_sprite.flip_h = direction < 0
		area_2d.position.x = abs(area_2d.position.x) * (-1 if anim_sprite.flip_h else 1)


	if Input.is_action_just_pressed("ATTACK") and not attacking:
		attacking = true
		play_anim("attack")
		
	if attacking:
		move_and_slide()
		was_on_floor = on_floor_now
		return

	if Input.is_action_just_pressed("JUMP") and on_floor_now and not jump_queued:
		jump_queued = true
		play_anim("pre_jump")

	if on_floor_now and not was_on_floor and not jump_queued:
		play_anim("land")

	elif not on_floor_now:
		if velocity.y < 0:
			play_anim("jump")
		else:
			play_anim("fall")
	elif not jump_queued:
		if direction != 0:
			play_anim("walk")
		else:
			play_anim("idle")

	move_and_slide()
	was_on_floor = on_floor_now


func play_anim(name: String) -> void:
	if anim_sprite.animation != name:
		if (name == "attack"):
			current_speed = 0.0
			collision_shape_2d.disabled = false	
		anim_sprite.play(name)


func _on_animation_finished() -> void:
	match anim_sprite.animation:
		"pre_jump":
			velocity.y = -JUMP_FORCE
			jump_queued = false
		"land":
			play_anim("idle")
		"attack":
			attacking = false
			current_speed = SPEED
			collision_shape_2d.disabled = true
			
			if not is_on_floor():
				if velocity.y < 0:
					play_anim("jump")
				else:
					play_anim("fall")
			elif velocity.x != 0:
				play_anim("walk")
			else:
				play_anim("idle")
