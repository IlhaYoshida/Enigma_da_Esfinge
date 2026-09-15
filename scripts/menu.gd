extends Node2D

@onready var botao_jogar = $BotaoJogar
@onready var botao_sair = $BotaoSair
@onready var barra_lateral = $BarraLateral

func _ready():
	botao_jogar.pressed.connect(_on_jogar)
	botao_sair.pressed.connect(_on_sair)
	barra_lateral.acao_pressionada.connect(_on_sair)

	botao_jogar.position.x = (1280 / 2) - (botao_jogar.size.x / 2)
	botao_sair.position.x = (1280 / 2) - (botao_sair.size.x / 2)
	botao_jogar.pivot_offset = botao_jogar.size / 2
	botao_sair.pivot_offset = botao_sair.size / 2
	botao_jogar.mouse_entered.connect(func(): botao_jogar.scale = Vector2(1.05, 1.05))
	botao_jogar.mouse_exited.connect(func(): botao_jogar.scale = Vector2(1.0, 1.0))
	botao_sair.mouse_entered.connect(func(): botao_sair.scale = Vector2(1.05, 1.05))
	botao_sair.mouse_exited.connect(func(): botao_sair.scale = Vector2(1.0, 1.0))

func _on_jogar():
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_sair():
	get_tree().quit()
