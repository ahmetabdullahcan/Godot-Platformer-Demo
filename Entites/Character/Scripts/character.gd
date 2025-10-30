extends CharacterBody2D

@export var SPEED := 60.0
const GRAVITY := 200.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if (not is_on_floor()):
		velocity.y += GRAVITY * delta
	var direction := Input.get_axis("MOVE_LEFT", "MOVE_RIGHT")
	
	velocity.x = direction * SPEED

	if anim_sprite:
		if direction != 0:
			anim_sprite.play("walk")  
			anim_sprite.flip_h = direction < 0
		else:
			anim_sprite.play("idle")

	move_and_slide()
