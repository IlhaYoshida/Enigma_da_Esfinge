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
@onready var balao = $Balao
@onready var imagem_animal = $Balao/ImagemAnimal
@onready var mao = $Mao
@onready var slots = $Slots
@onready var audio_player = $AudioPlayer
@onready var loading_screen = $LoadingScreen
@onready var placar = $Placar
@onready var barra_lateral = $BarraLateral

@onready var tutorial_overlay = $TutorialOverlay
@onready var tutorial_cursor = $TutorialOverlay/Cursor
@onready var tutorial_audio = $TutorialOverlay/VozTutorial
@onready var botao_pular_tutorial = $TutorialOverlay/BotaoPularTutorial

# Falas gravadas do tutorial, na ordem em que tocam.
var vozes_tutorial: Array[AudioStream] = [
	preload("res://assets/audio/tutorial/tutorial_1.mp3"),
	preload("res://assets/audio/tutorial/tutorial_2.mp3"),
	preload("res://assets/audio/tutorial/tutorial_3.mp3"),
	preload("res://assets/audio/tutorial/tutorial_4.mp3"),
	preload("res://assets/audio/tutorial/tutorial_5.mp3"),
	preload("res://assets/audio/tutorial/tutorial_6.mp3"),
	preload("res://assets/audio/tutorial/tutorial_7.mp3"),
]

var _tutorial_pulado := false
signal _tutorial_interromper

func _ready():
	barra_lateral.acao_pressionada.connect(_on_voltar_ao_menu)
	botao_pular_tutorial.pressed.connect(_on_pular_tutorial_pressed)
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

	await get_tree().process_frame
	await tutorial()

func _on_voltar_ao_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

# ---------------------------------------------------------------------------
# TUTORIAL
# Roda automaticamente assim que a primeira rodada é montada (logo depois de
# clicar em "Jogar"). Não usa texto: uma voz narra enquanto uma "mãozinha"
# (cursor falso) aponta e arrasta as peças de verdade na tela. Pode ser
# interrompido a qualquer momento pelo botão de pular no canto superior
# direito.
# ---------------------------------------------------------------------------

func tutorial() -> void:
	Global.tutorial_ativo = true
	_tutorial_pulado = false
	tutorial_cursor.visible = true
	tutorial_cursor.scale = Vector2(1.0, 1.0)
	tutorial_cursor.modulate.a = 1.0
	botao_pular_tutorial.visible = true

	# Ponto central da fileira de sílabas (a "Mao" em si não tem posição
	# própria; suas peças-filhas é que ficam posicionadas na fileira).
	var centro_silabas := Vector2.ZERO
	for p in posicoes_silabas:
		centro_silabas += p
	if posicoes_silabas.size() > 0:
		centro_silabas /= posicoes_silabas.size()

	# Ícone de acerto/erro do placar, para apontar algo visível (não o Node2D
	# "Placar" em si, que fica na origem e não é desenhado sozinho).
	var pos_placar: Vector2 = placar.get_node("Acerto1").global_position

	var slot_alvo = slots.get_child(0)
	var silaba_certa = _achar_silaba_por_texto(silabas_corretas[0])
	var silaba_errada = _achar_silaba_diferente(silabas_corretas[0])

	var passos := [
		{"pos": balao.global_position, "audio": vozes_tutorial[0]},
		{"pos": centro_silabas, "audio": vozes_tutorial[1]},
		{"alvo": silaba_errada, "audio": vozes_tutorial[2], "slot": slot_alvo, "resultado": "erro"},
		{"audio": vozes_tutorial[3]},
		{"alvo": silaba_certa, "audio": vozes_tutorial[4], "slot": slot_alvo, "resultado": "acerto"},
		{"pos": pos_placar, "audio": vozes_tutorial[5]},
		{"audio": vozes_tutorial[6], "esconder_cursor": true},
	]

	for passo in passos:
		if _tutorial_pulado:
			break

		_parar_idle_cursor()

		# A partir daqui a mãozinha já mostrou tudo que precisava mostrar —
		# some suavinho da tela em vez de ficar parada sem função nenhuma
		# durante a fala final.
		if passo.get("esconder_cursor", false):
			if await _esconder_cursor():
				break

		var alvo = passo.get("alvo")
		var tem_pos = passo.has("alvo") or passo.has("pos")
		var pos_alvo: Vector2 = alvo.global_position if passo.has("alvo") else passo.get("pos", Vector2.ZERO)
		if tem_pos:
			if await _mover_cursor_para(pos_alvo):
				break

		if passo.has("slot"):
			if await _demonstrar_arraste(alvo, passo["slot"], passo["resultado"]):
				break

		# Um pequeno "respirar" no cursor enquanto a voz fala, pra não parecer
		# que a tela travou durante a narração (só faz sentido se ele ainda
		# estiver visível).
		if not passo.get("esconder_cursor", false):
			_iniciar_idle_cursor()

		var audio: AudioStream = passo["audio"]
		tutorial_audio.stream = audio
		tutorial_audio.play()
		# Nunca espera mais do que a duração real do áudio (+ uma folga).
		# Isso garante que o tutorial SEMPRE avança, mesmo se o sinal
		# "finished" não disparar direito em algum computador/driver de
		# áudio específico — sem isso, um travamento nesse sinal deixava
		# o mesmo trecho tocando pra sempre.
		var limite = audio.get_length() + 1.5 if audio else 6.0
		if await _esperar_ou_pular(tutorial_audio.finished, limite):
			break

	_finalizar_tutorial()

func _mover_cursor_para(destino: Vector2) -> bool:
	var tween = create_tween()
	tween.tween_property(tutorial_cursor, "global_position", destino, 0.7)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	return await _esperar_ou_pular(tween.finished, 0.7 + 1.0)

## Faz a mãozinha encolher e desaparecer suavemente (ela já mostrou tudo que
## precisava mostrar, não faz mais sentido deixar ela parada na tela).
func _esconder_cursor() -> bool:
	_parar_idle_cursor()
	var tween = create_tween()
	tween.tween_property(tutorial_cursor, "scale", Vector2.ZERO, 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(tutorial_cursor, "modulate:a", 0.0, 0.4)
	var pulou = await _esperar_ou_pular(tween.finished, 0.4 + 1.0)
	tutorial_cursor.visible = false
	return pulou

func _demonstrar_arraste(silaba, slot, resultado: String) -> bool:
	var pos_original = silaba.global_position
	var tween = create_tween()
	tween.tween_property(silaba, "global_position", slot.global_position, 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(tutorial_cursor, "global_position", slot.global_position, 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var pulou = await _esperar_ou_pular(tween.finished, 0.6 + 1.0)

	if resultado == "acerto":
		esfinge.texture = load("res://assets/esfinge/esfinge_acerto.png")
	else:
		esfinge.texture = load("res://assets/esfinge/esfinge_erro.png")

	if not pulou:
		await get_tree().create_timer(0.5).timeout

	esfinge.texture = load("res://assets/esfinge/esfinge_padrao.png")

	# Volta a sílaba pro lugar dela de um jeito suave (com uma animação),
	# em vez de simplesmente "teletransportar" ela de volta.
	var tween_volta = create_tween()
	tween_volta.tween_property(silaba, "global_position", pos_original, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if not pulou:
		await _esperar_ou_pular(tween_volta.finished, 0.4 + 1.0)
	else:
		silaba.global_position = pos_original

	return pulou

## Espera o sinal "sig" terminar, mas para de esperar na hora se "Pular" for
## apertado, e NUNCA espera mais do que "tempo_limite" segundos (se maior que
## zero) — isso é uma rede de segurança: se por qualquer motivo o sinal não
## disparar num computador específico, o tutorial segue em frente assim mesmo
## em vez de travar pra sempre. Retorna true se foi interrompido pelo pulo.
func _esperar_ou_pular(sig: Signal, tempo_limite: float = -1.0) -> bool:
	if _tutorial_pulado:
		return true
	# Usa um Array como "caixinha" compartilhada: lambdas em GDScript capturam
	# variáveis simples (bool/int) por valor, então um "var feito := false"
	# comum nunca seria realmente alterado pelo callback do sinal. Um Array
	# é um objeto e é compartilhado de verdade entre a lambda e este loop.
	var estado := [false, false] # [feito, pulou]
	var ao_sinal := func(_a = null, _b = null, _c = null, _d = null):
		estado[0] = true
	var ao_pular := func():
		estado[0] = true
		estado[1] = true
	sig.connect(ao_sinal, CONNECT_ONE_SHOT)
	_tutorial_interromper.connect(ao_pular, CONNECT_ONE_SHOT)

	var timer_seguranca: SceneTreeTimer = null
	var ao_estourar_tempo := func():
		estado[0] = true
	if tempo_limite > 0.0:
		timer_seguranca = get_tree().create_timer(tempo_limite)
		timer_seguranca.timeout.connect(ao_estourar_tempo, CONNECT_ONE_SHOT)

	while not estado[0]:
		await get_tree().process_frame

	if sig.is_connected(ao_sinal):
		sig.disconnect(ao_sinal)
	if _tutorial_interromper.is_connected(ao_pular):
		_tutorial_interromper.disconnect(ao_pular)
	if timer_seguranca and timer_seguranca.timeout.is_connected(ao_estourar_tempo):
		timer_seguranca.timeout.disconnect(ao_estourar_tempo)
	return estado[1]

func _on_pular_tutorial_pressed() -> void:
	if _tutorial_pulado:
		return
	_tutorial_pulado = true
	_tutorial_interromper.emit()

var _tween_idle: Tween = null

func _iniciar_idle_cursor() -> void:
	_parar_idle_cursor()
	_tween_idle = create_tween()
	_tween_idle.set_loops()
	_tween_idle.tween_property(tutorial_cursor, "scale", Vector2(1.1, 1.1), 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween_idle.tween_property(tutorial_cursor, "scale", Vector2(1.0, 1.0), 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _parar_idle_cursor() -> void:
	if _tween_idle and _tween_idle.is_valid():
		_tween_idle.kill()
	_tween_idle = null
	if tutorial_cursor:
		tutorial_cursor.scale = Vector2(1.0, 1.0)

func _finalizar_tutorial() -> void:
	_parar_idle_cursor()
	tutorial_audio.stop()
	tutorial_cursor.visible = false
	tutorial_cursor.scale = Vector2(1.0, 1.0)
	tutorial_cursor.modulate.a = 1.0
	botao_pular_tutorial.visible = false
	Global.tutorial_ativo = false

	# Garante que nenhuma sílaba ficou fora do lugar por causa da demonstração.
	for i in range(mao.get_child_count()):
		mao.get_child(i).global_position = posicoes_silabas[i]
	esfinge.texture = load("res://assets/esfinge/esfinge_padrao.png")

func _achar_silaba_por_texto(texto: String):
	for i in range(mao.get_child_count()):
		var silaba = mao.get_child(i)
		if silaba.get_node("Label").text == texto:
			return silaba
	return mao.get_child(0)

func _achar_silaba_diferente(texto: String):
	for i in range(mao.get_child_count()):
		var silaba = mao.get_child(i)
		if silaba.get_node("Label").text != texto:
			return silaba
	return mao.get_child(0)

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
		# O som da sílaba agora toca ao passar o mouse por cima dela
		# (silaba.gd), não mais aqui quando ela é encaixada.

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
