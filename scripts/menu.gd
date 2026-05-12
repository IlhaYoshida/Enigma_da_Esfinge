extends Node2D

@onready var botao_jogar = $BotaoJogar
@onready var botao_som = $BotaoSom
@onready var botao_sair = $BotaoSair
@onready var slider_volume = $SliderVolume

var som_ativo = true

func _ready():
	botao_som.text = "🔊"
	botao_jogar.pressed.connect(_on_jogar)
	botao_som.pressed.connect(_on_toggle_som)
	botao_sair.pressed.connect(_on_sair)
	slider_volume.value_changed.connect(_on_volume_changed)
	slider_volume.min_value = 0
	slider_volume.max_value = 1
	slider_volume.step = 0.05
	slider_volume.value = 1.0
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

func _on_toggle_som():
	som_ativo = !som_ativo
	if som_ativo:
		AudioServer.set_bus_mute(0, false)
		botao_som.text = "🔊"
	else:
		AudioServer.set_bus_mute(0, true)
		botao_som.text = "🔇"

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_sair():
	get_tree().quit()
