extends Node

var musica_player = AudioStreamPlayer.new()

var JsonRequest = HTTPRequest.new()
var ImagemRequest = HTTPRequest.new()
var AudioRequest = HTTPRequest.new()
var AudioSilabaRequest = HTTPRequest.new()

var array_dicionario: Array
var array_dicionario_imagens: Array
var texturas: Array
var audio_palavra
var audios_silabas: Array = []
var cont_silaba: int = 0

var index = 0
var cont_img = 0

var array_palavras: Array = []
var array_imagens: Array = []
var dados_prontos: bool = false

var dicionario: Dictionary = {
	"palavra": "",
	"silabas": [],
	"imagens": null,
	"som": null
}

var Score: int = 0
var erros: int = 0

func _ready() -> void:
	# Música de fundo
	add_child(musica_player)
	musica_player.stream = load("res://assets/musica.mp3")
	musica_player.volume_db = -10
	musica_player.play()

	# Requisições
	add_child(JsonRequest)
	add_child(ImagemRequest)
	add_child(AudioRequest)
	add_child(AudioSilabaRequest)
	JsonRequest.request_completed.connect(_on_json_request_completed)
	ImagemRequest.request_completed.connect(_on_imagem_request_completed)
	AudioRequest.request_completed.connect(_on_audio_palavra_completed)
	AudioSilabaRequest.request_completed.connect(_on_audio_silaba_completed)

	var url = "http://localhost:8080/api/recursos/palavras?vogal=A&limite=9&tipoColorir=NAO_COLORIR&quantImagens=1"
	var headers = ["Content-Type: application/json"]
	JsonRequest.request(url, headers, HTTPClient.METHOD_GET)

func _on_json_request_completed(_result, _response_code, _headers, body: PackedByteArray) -> void:
	var json_string = body.get_string_from_utf8()
	var json = JSON.parse_string(json_string)
	array_dicionario = json
	print("Palavras recebidas: ", array_dicionario.size())
	request_imagem()

func request_imagem() -> void:
	if index == array_dicionario.size():
		dados_prontos = true
		print("Todos os dados prontos! Total de palavras: ", array_palavras.size())
		return
	array_dicionario_imagens = array_dicionario[index].imagens
	if cont_img < array_dicionario_imagens.size():
		ImagemRequest.request(array_dicionario_imagens[cont_img].imagem)
		cont_img += 1

func _on_imagem_request_completed(_result, _response_code, _headers, body: PackedByteArray) -> void:
	var image = Image.new()
	image.load_png_from_buffer(body)
	var texture = ImageTexture.create_from_image(image)
	texturas.append(texture)
	if cont_img < array_dicionario_imagens.size():
		request_imagem()
	else:
		AudioRequest.request(array_dicionario[index].som)

func _on_audio_palavra_completed(_result, _response_code, _headers, body: PackedByteArray) -> void:
	audio_palavra = AudioStreamOggVorbis.load_from_buffer(body)
	cont_silaba = 0
	audios_silabas.clear()
	request_audio_silaba()

func request_audio_silaba() -> void:
	var silabas = array_dicionario[index].silabas
	if cont_silaba < silabas.size():
		AudioSilabaRequest.request(silabas[cont_silaba].som)
		cont_silaba += 1
	else:
		cria_dicionario()

func _on_audio_silaba_completed(_result, _response_code, _headers, body: PackedByteArray) -> void:
	var audio_silaba = AudioStreamOggVorbis.load_from_buffer(body)
	audios_silabas.append(audio_silaba)
	request_audio_silaba()

func cria_dicionario() -> void:
	var silabas_raw = array_dicionario[index].silabas
	print("Criando dicionário para: ", array_dicionario[index].palavra, " - sílabas: ", silabas_raw.size(), " - áudios: ", audios_silabas.size())
	var silabas_completas = []
	for i in range(silabas_raw.size()):
		silabas_completas.append({
			"posicao": silabas_raw[i].posicao,
			"silaba": silabas_raw[i].silaba,
			"som": audios_silabas[i]
		})
	dicionario = {
		"palavra": array_dicionario[index].palavra,
		"silabas": silabas_completas,
		"imagens": texturas.duplicate(),
		"som": audio_palavra
	}
	array_palavras.append(dicionario)
	index += 1
	print("Palavra processada: ", dicionario.palavra)
	cont_img = 0
	texturas.clear()
	audio_palavra = null
	audios_silabas.clear()
	request_imagem()

func embaralhar() -> void:
	array_palavras.shuffle()
	array_imagens = array_palavras[0].imagens
	array_imagens.shuffle()
