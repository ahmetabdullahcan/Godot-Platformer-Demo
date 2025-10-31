extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

var is_taking_damage: bool = false

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Sinyal bağlantısı artık doğru: area_entered
	area.area_entered.connect(_on_area_entered) # <-- Fonksiyon ismini güncelledik

# Sinyal alıcısı fonksiyonunu güncelleyin:
# body yerine area parametresi kullanmak daha doğru olur.
func _on_area_entered(area_hit): # <-- Parametreyi body yerine area_hit yaptık
	print("ANAN - Çarpışma Başarılı!")
	if not is_taking_damage:
		_take_damage()

func _take_damage():
	is_taking_damage = true
	animated_sprite.animation = "take_damage"
	animated_sprite.play()

func _on_animation_finished():
	if animated_sprite.animation == "take_damage":
		is_taking_damage = false
		animated_sprite.animation = "idle"
		animated_sprite.play()
