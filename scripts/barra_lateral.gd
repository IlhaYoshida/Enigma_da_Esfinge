extends Node2D

## Barra lateral reutilizável (som + volume da música + ação de voltar/sair).
## Usada tanto no menu quanto dentro do jogo.

signal acao_pressionada

## Textura do ícone de ação (porta = sair do jogo, seta = voltar ao menu).
@export var icone_acao: Texture2D
@export var icone_acao_hover: Texture2D

const BUS_MUSICA := "Musica"

@onready var fundo = $Fundo
@onready var botao_som = $BotaoSom
@onready var botao_acao = $BotaoAcao
@onready var slider_volume = $SliderVolume

var icone_com_som := preload("res://assets/ui/volume.png")
var icone_sem_som := preload("res://assets/ui/muted.png")
var fundo_padrao := preload("res://assets/ui/menu_fixo.png")
var fundo_foco_som := preload("res://assets/ui/menu_fixo_som.png")
var fundo_foco_acao := preload("res://assets/ui/menu_fixo_porta.png")

var som_ativo = true

func _ready():
	if icone_acao:
		botao_acao.texture_normal = icone_acao
	botao_acao.texture_hover = icone_acao_hover if icone_acao_hover else icone_acao

	botao_som.pressed.connect(_on_toggle_som)
	botao_acao.pressed.connect(func(): acao_pressionada.emit())

	slider_volume.min_value = 0
	slider_volume.max_value = 1
	slider_volume.step = 0.05
	slider_volume.value_changed.connect(_on_volume_changed)

	var idx = _bus_musica()
	som_ativo = not AudioServer.is_bus_mute(idx)
	slider_volume.value = db_to_linear(AudioServer.get_bus_volume_db(idx))
	botao_som.texture_normal = icone_com_som if som_ativo else icone_sem_som

	botao_som.mouse_entered.connect(func(): fundo.texture = fundo_foco_som)
	botao_som.mouse_exited.connect(func(): fundo.texture = fundo_padrao)
	botao_acao.mouse_entered.connect(func(): fundo.texture = fundo_foco_acao)
	botao_acao.mouse_exited.connect(func(): fundo.texture = fundo_padrao)

## Garante que existe um bus de áudio separado só para a música
## (assim essa barra nunca mexe no volume das sílabas/efeitos, que
## continuam tocando no bus "Master").
func _bus_musica() -> int:
	var idx = AudioServer.get_bus_index(BUS_MUSICA)
	if idx == -1:
		idx = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, BUS_MUSICA)
		AudioServer.set_bus_send(idx, "Master")
	return idx

func _on_toggle_som():
	som_ativo = not som_ativo
	AudioServer.set_bus_mute(_bus_musica(), not som_ativo)
	botao_som.texture_normal = icone_com_som if som_ativo else icone_sem_som

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(_bus_musica(), linear_to_db(value))
