extends Node2D


func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("QUIT")):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
