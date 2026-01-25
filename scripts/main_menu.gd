extends Control

@onready var hover_sound = $hover_sound
@onready var click_sound = $click_sound

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	click_sound.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_options_pressed() -> void:
	print("options pressed")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_mouse_entered() -> void:
	hover_sound.play()


func _on_options_mouse_entered() -> void:
	hover_sound.play()


func _on_quit_mouse_entered() -> void:
	hover_sound.play()
