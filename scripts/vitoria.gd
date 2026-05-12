extends Node2D

@onready var botao = $BotaoMenu

func _ready():
	botao.pressed.connect(_on_menu)
	await get_tree().process_frame
	botao.pivot_offset = botao.size / 2
	botao.position.x = (1280 / 2) - (botao.size.x / 2)
	botao.mouse_entered.connect(func(): botao.scale = Vector2(1.05, 1.05))
	botao.mouse_exited.connect(func(): botao.scale = Vector2(1.0, 1.0))

func _on_menu():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
