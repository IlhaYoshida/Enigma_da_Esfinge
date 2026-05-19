extends Node

var musica_player = AudioStreamPlayer.new()
var array_palavras: Array = []
var dados_prontos: bool = false

func _ready() -> void:
	# Música de fundo
	add_child(musica_player)
	musica_player.stream = load("res://assets/musica.mp3")
	musica_player.volume_db = -10
	musica_player.play()

	# Carrega as palavras do JSON local
	carregar_dados_locais()

func carregar_dados_locais() -> void:
	# Abre o arquivo JSON salvo no projeto
	var file = FileAccess.open("res://data/palavras.json", FileAccess.READ)
	
	if file:
		var json_string = file.get_as_text()
		var json = JSON.parse_string(json_string)
		
		# Monta o array_palavras exatamente como o game_scene.gd espera
		for item in json:
			var dicionario = {
				"palavra": item.palavra,
				"silabas": [],
				"imagens": [],
				"som": load(item.som) if item.som != null else null
			}
			
			# Carrega as texturas das imagens
			for img in item.imagens:
				var textura = load(img.imagem)
				if textura:
					dicionario.imagens.append(textura)
			
			# Carrega os áudios das sílabas
			for silaba in item.silabas:
				dicionario.silabas.append({
					"posicao": silaba.posicao,
					"silaba": silaba.silaba,
					"som": load(silaba.som) if silaba.som != null else null
				})
				
			array_palavras.append(dicionario)
			print("Palavra carregada na memória: ", dicionario.palavra)
			
		dados_prontos = true
		print("Todos os dados prontos! Total de palavras: ", array_palavras.size())
	else:
		print("ERRO: Não foi possível encontrar o arquivo res://data/palavras.json")
