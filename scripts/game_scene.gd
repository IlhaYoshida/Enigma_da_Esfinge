extends Node2D

var palavra_atual = ""
var silabas_corretas = []
var slots_preenchidos = []
var posicoes_silabas = []
var palavras_usadas = []
var audios_silabas_atual = {}
var total_acertos = 0
var total_erros = 0

@onready var esfinge = $Esfinge
@onready var imagem_animal = $Balao/ImagemAnimal
@onready var mao = $Mao
@onready var slots = $Slots
@onready var audio_player = $AudioPlayer
@onready var loading_screen = $LoadingScreen
@onready var placar = $Placar

func _ready():
	loading_screen.visible = true
	await get_tree().process_frame

	var total_silabas = mao.get_child_count()
	var largura_silaba = 120
	var espaco = 20
	var total_largura = (total_silabas * largura_silaba) + ((total_silabas - 1) * espaco)
	var inicio_x = (1280 - total_largura) / 2 + largura_silaba / 2
	var y_silabas = 650

	for i in range(total_silabas):
		var silaba = mao.get_child(i)
		silaba.global_position = Vector2(inicio_x + i * (largura_silaba + espaco), y_silabas)
		posicoes_silabas.append(silaba.global_position)

	var total_slots = slots.get_child_count()
	var largura_slot = 120
	var espaco_slot = 30
	var total_largura_slots = (total_slots * largura_slot) + ((total_slots - 1) * espaco_slot)
	var inicio_x_slots = (1280 - total_largura_slots) / 2 + largura_slot / 2
	var y_slots = 420

	for i in range(total_slots):
		var slot = slots.get_child(i)
		slot.global_position = Vector2(inicio_x_slots + i * (largura_slot + espaco_slot), y_slots)

	atualizar_placar()
	print("Aguardando dados da API...")
	await esperar_dados()
	print("Iniciando rodada!")
	loading_screen.visible = false
	iniciar_rodada()

func esperar_dados() -> void:
	while not Global.dados_prontos:
		print("Dados ainda não prontos, aguardando...")
		await get_tree().create_timer(0.5).timeout

func atualizar_placar():
	for i in range(3):
		placar.get_node("Acerto" + str(i + 1)).visible = i < total_acertos
		placar.get_node("Erro" + str(i + 1)).visible = i < total_erros

func iniciar_rodada():
	for i in range(mao.get_child_count()):
		var silaba = mao.get_child(i)
		silaba.global_position = posicoes_silabas[i]
		silaba.posicao_original = posicoes_silabas[i]

	if palavras_usadas.size() == Global.array_palavras.size():
		palavras_usadas.clear()

	var disponiveis = Global.array_palavras.filter(func(p): return not palavras_usadas.has(p.palavra))
	disponiveis.shuffle()
	var dados = disponiveis[0]

	palavra_atual = dados.palavra
	silabas_corretas = []
	for s in dados.silabas:
		silabas_corretas.append(s.silaba)

	audios_silabas_atual = {}
	for s in dados.silabas:
		audios_silabas_atual[s.silaba] = s.som

	palavras_usadas.append(palavra_atual)

	slots_preenchidos = []
	for i in range(silabas_corretas.size()):
		slots_preenchidos.append("")

	ajustar_slots(silabas_corretas.size())
	imagem_animal.texture = dados.imagens[0]
	montar_mao(dados)

func ajustar_slots(quantidade: int):
	var largura_slot = 120
	var espaco_slot = 30
	var total_largura_slots = (quantidade * largura_slot) + ((quantidade - 1) * espaco_slot)
	var inicio_x_slots = (1280 - total_largura_slots) / 2 + largura_slot / 2
	var y_slots = 420

	for i in range(slots.get_child_count()):
		var slot = slots.get_child(i)
		if i < quantidade:
			slot.visible = true
			slot.global_position = Vector2(inicio_x_slots + i * (largura_slot + espaco_slot), y_slots)
		else:
			slot.visible = false

func montar_mao(dados):
	var silabas_mao = []
	for s in dados.silabas:
		silabas_mao.append(s.silaba)

	var distratoras = []
	for p in Global.array_palavras:
		if p.palavra != palavra_atual:
			for s in p.silabas:
				if not silabas_mao.has(s.silaba) and not distratoras.has(s.silaba):
					distratoras.append(s.silaba)

	distratoras.shuffle()

	var idx = 0
	while silabas_mao.size() < 6 and idx < distratoras.size():
		silabas_mao.append(distratoras[idx])
		idx += 1

	silabas_mao.shuffle()

	for i in range(mao.get_child_count()):
		var silaba = mao.get_child(i)
		var label = silaba.get_node("Label")
		if i < silabas_mao.size():
			label.text = silabas_mao[i]
		else:
			label.text = "?"

func tentar_encaixar(silaba, indice_slot):
	if not slots.get_child(indice_slot).visible:	
		silaba.global_position = silaba.posicao_original
		return

	var texto = silaba.get_node("Label").text
	if slots_preenchidos[indice_slot] != "":
		silaba.global_position = silaba.posicao_original
		return

	if texto == silabas_corretas[indice_slot]:
		slots_preenchidos[indice_slot] = texto
		silaba.global_position = slots.get_child(indice_slot).global_position
		silaba.arrastando = false
		esfinge.texture = load("res://assets/esfinge/esfinge_acerto.png")

		if audios_silabas_atual.has(texto):
			audio_player.stream = audios_silabas_atual[texto]
			audio_player.volume_db = 10
			audio_player.play()

		if slots_preenchidos == silabas_corretas:
			total_acertos += 1
			atualizar_placar()
			await get_tree().create_timer(1.5).timeout
			esfinge.texture = load("res://assets/esfinge/esfinge_padrao.png")

			if total_acertos >= 3:
				get_tree().change_scene_to_file("res://scenes/vitoria.tscn")
			else:
				iniciar_rodada()
	else:
		total_erros += 1
		atualizar_placar()
		esfinge.texture = load("res://assets/esfinge/esfinge_erro.png")
		silaba.global_position = silaba.posicao_original
		await get_tree().create_timer(1.0).timeout
		esfinge.texture = load("res://assets/esfinge/esfinge_padrao.png")

		if total_erros >= 3:
			get_tree().change_scene_to_file("res://scenes/derrota.tscn")
