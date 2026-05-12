extends Node

@onready var video = $Video

func _ready():
	video.play()
	video.finished.connect(_on_video_finished)

func _on_video_finished():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
