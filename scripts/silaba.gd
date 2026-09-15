extends Node2D

var arrastando = false
var posicao_original = Vector2()
var tamanho = Vector2(120, 120)

# Controla se o mouse já estava em cima da peça no frame anterior, pra tocar
# o som só uma vez quando o mouse "entra" nela (e não repetir toda hora
# enquanto ele fica parado em cima).
var _mouse_em_cima = false

func _ready():
	await get_tree().process_frame
	posicao_original = global_position

func _input(event):
	if Global.tutorial_ativo:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse = get_global_mouse_position()
				var rect = Rect2(global_position - tamanho/2, tamanho)
				if rect.has_point(mouse):
					arrastando = true
					get_viewport().set_input_as_handled()
			else:
				if arrastando:
					arrastando = false
					verificar_slot()

func _process(_delta):
	if arrastando:
		global_position = get_global_mouse_position()
		return

	if Global.tutorial_ativo:
		return

	# O som da sílaba toca quando o mouse passa por cima dela (não mais só
	# quando ela é arrastada e encaixada certinho no quadrado).
	var mouse = get_global_mouse_position()
	var rect = Rect2(global_position - tamanho / 2, tamanho)
	var esta_em_cima = rect.has_point(mouse)
	if esta_em_cima and not _mouse_em_cima:
		_tocar_som_hover()
	_mouse_em_cima = esta_em_cima

func _tocar_som_hover() -> void:
	var game = get_tree().get_root().get_node_or_null("GameScene")
	if not game:
		return
	var texto = get_node("Label").text
	# Usa o dicionário global com o som de TODAS as sílabas do jogo, não só
	# das que pertencem à palavra da rodada — assim as sílabas "isca" de
	# outras palavras (ex: "CA" numa rodada de "SALADA") também têm som.
	if Global.sons_silabas.has(texto) and Global.sons_silabas[texto] != null:
		game.audio_player.stream = Global.sons_silabas[texto]
		game.audio_player.volume_db = 10
		game.audio_player.play()

func verificar_slot():
	var game = get_tree().get_root().get_node("GameScene")
	var slots = game.get_node("Slots")
	for i in range(slots.get_child_count()):
		var slot = slots.get_child(i)
		var distancia = global_position.distance_to(slot.global_position)
		if distancia < 80:
			game.tentar_encaixar(self, i)
			return
	global_position = posicao_original
