extends CharacterBody2D

@export var SPEED := 60.0
const GRAVITY := 200.0
const JUMP_FORCE := 150.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
var jump_queued := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Eğer pre_jump oynuyorsa, bekliyoruz
	if jump_queued and anim_sprite.animation == "pre_jump" and not anim_sprite.is_playing():
		velocity.y = -JUMP_FORCE
		jump_queued = false

	if Input.is_action_just_pressed("JUMP") and is_on_floor() and not jump_queued:
		jump_queued = true
		anim_sprite.play("pre_jump")

	var direction := Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	velocity.x = direction * SPEED

	if anim_sprite:
		if not is_on_floor():
			if velocity.y < 0:
				anim_sprite.play("jump")
			else:
				anim_sprite.play("fall")
		elif not jump_queued:
			if anim_sprite.animation == "fall":
				anim_sprite.play("land")
			elif direction != 0:
				anim_sprite.play("walk")
				anim_sprite.flip_h = direction < 0
			else:
				anim_sprite.play("idle")

	move_and_slide()
