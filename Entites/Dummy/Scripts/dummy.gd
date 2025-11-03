extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var damage_label: Label = $DamageLabel

var is_taking_damage: bool = false
var health: int = 100
var max_health: int = 100
var damage_timer: Timer
var flash_tween: Tween

const RECOVER_TIME := 0.2
const FLASH_COLOR := Color(1, 0.3, 0.3)

var damage_queue: Array = []
var is_showing_damage: bool = false

func _ready() -> void:
	if not animated_sprite or not area:
		push_error("AnimatedSprite2D veya Area2D bulunamadı!")
		return
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	area.area_entered.connect(_on_area_entered)
	
	damage_timer = Timer.new()
	damage_timer.wait_time = RECOVER_TIME
	damage_timer.one_shot = true
	add_child(damage_timer)
	
	if health_bar:
		health_bar.visible = true
		health_bar.max_value = max_health
		health_bar.min_value = 0
		health_bar.value = health
		health_bar.show_percentage = false
		
		health_bar.size = Vector2(20, 3)
		health_bar.position = Vector2(-10, -20) 
		
		health_bar.z_index = 10
		
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = Color(0, 0.8, 0)
		stylebox.border_width_left = 1
		stylebox.border_width_right = 1
		stylebox.border_width_top = 1
		stylebox.border_width_bottom = 1
		stylebox.border_color = Color.BLACK
		
		var stylebox_bg = StyleBoxFlat.new()
		stylebox_bg.bg_color = Color(0.3, 0.3, 0.3)
		stylebox_bg.border_width_left = 1
		stylebox_bg.border_width_right = 1
		stylebox_bg.border_width_top = 1
		stylebox_bg.border_width_bottom = 1
		stylebox_bg.border_color = Color.BLACK
		
		health_bar.add_theme_stylebox_override("fill", stylebox)
		health_bar.add_theme_stylebox_override("background", stylebox_bg)
		
		print("Can barı ayarlandı: ", health_bar.value, "/", health_bar.max_value)
	else:
		push_error("HealthBar bulunamadı!")
	
	if damage_label:
		damage_label.visible = false

func _on_area_entered(area_hit):
	if not is_taking_damage and damage_timer.is_stopped():
		if area_hit.has_meta("damage"):
			var damage = area_hit.get_meta("damage")
			_take_damage(damage)
			damage_timer.start()

func _take_damage(amount: int):
	is_taking_damage = true
	health -= amount
	if health < 0:
		health = 0
	
	if health_bar:
		health_bar.value = health
		print("Can güncellendi: ", health, "/", max_health)
	
	if damage_label:
		damage_queue.append(amount)
		if not is_showing_damage:
			_show_next_damage()
	
	if flash_tween:
		flash_tween.kill()
	
	animated_sprite.modulate = FLASH_COLOR
	flash_tween = create_tween()
	if flash_tween:
		flash_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.3)
	
	animated_sprite.animation = "take_damage"
	animated_sprite.play()
	
	if health <= 0:
		die()

func _show_next_damage():
	if damage_queue.is_empty():
		is_showing_damage = false
		return
	
	is_showing_damage = true
	var amount = damage_queue.pop_front()
	
	if not is_instance_valid(damage_label):
		is_showing_damage = false
		return
	
	damage_label.text = str("-", amount)
	damage_label.visible = true
	damage_label.modulate = Color(1, 0.2, 0.2, 1.0)
	damage_label.position = Vector2(randf_range(-10, 10), -20)
	
	var tween = create_tween()
	if tween and is_instance_valid(damage_label):
		tween.tween_property(damage_label, "position:y", damage_label.position.y - 20, 0.4)
		tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 0.4)
		tween.finished.connect(func():
			if is_instance_valid(damage_label):
				damage_label.visible = false
				_show_next_damage()
		)

func die():
	if flash_tween:
		flash_tween.kill()
	queue_free()

func _on_animation_finished():
	if animated_sprite.animation == "take_damage":
		is_taking_damage = false
		animated_sprite.animation = "idle"
		animated_sprite.play()
