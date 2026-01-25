extends TextureButton

@export var icon_on: Texture2D
@export var icon_off: Texture2D

@onready var music_player := get_node("/root/Main/MusicPlayer")

func _ready() -> void:
	# Make this a toggle button
	toggle_mode = true
	button_pressed = true
	texture_normal = icon_on

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Music ON
		music_player.volume_db = -12
		texture_normal = icon_on
	else:
		# Music OFF
		music_player.volume_db = -80
		texture_normal = icon_off
