extends Node2D

var arrastando = false
var posicao_original = Vector2()
var tamanho = Vector2(120, 120)

func _ready():
	await get_tree().process_frame
	posicao_original = global_position

func _input(event):
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
