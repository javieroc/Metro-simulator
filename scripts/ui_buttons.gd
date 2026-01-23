extends Control

@onready var click_sound = $AudioStreamPlayer
@onready var start_button = $Buttons/Start

func _ready():
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	if click_sound:
		click_sound.play()
