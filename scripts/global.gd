extends Node

var musica_player = AudioStreamPlayer.new()
var array_palavras: Array = []
var dados_prontos: bool = false

# Som de CADA sílaba que existe no jogo (de todas as palavras, não só da
# palavra da rodada atual) — assim toda peça que aparece na fileira tem som
# ao passar o mouse por cima, mesmo as sílabas "isca" de outras palavras.
var sons_silabas: Dictionary = {}

# Enquanto o tutorial estiver rodando, as sílabas não respondem a cliques/arraste
# (evita que a criança mexa no jogo de verdade por engano durante a demonstração).
var tutorial_ativo: bool = false

const BUS_MUSICA := "Musica"

func _ready() -> void:
	# Bus de áudio exclusivo para a música, separado do "Master".
	# Assim a barra de volume do menu/jogo controla só a música,
	# sem afetar o som das sílabas (que continua no bus "Master").
	if AudioServer.get_bus_index(BUS_MUSICA) == -1:
		var idx = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, BUS_MUSICA)
		AudioServer.set_bus_send(idx, "Master")

	# Música de fundo
	add_child(musica_player)
	musica_player.stream = load("res://assets/musica.mp3")
	musica_player.bus = BUS_MUSICA
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
				var som_silaba = load(silaba.som) if silaba.som != null else null
				dicionario.silabas.append({
					"posicao": silaba.posicao,
					"silaba": silaba.silaba,
					"som": som_silaba
				})

				# Guarda o som dessa sílaba pra qualquer palavra que a
				# usar (inclusive como "isca"/distratora em outra rodada).
				if som_silaba != null and not sons_silabas.has(silaba.silaba):
					sons_silabas[silaba.silaba] = som_silaba

			array_palavras.append(dicionario)
			print("Palavra carregada na memória: ", dicionario.palavra)
			
		dados_prontos = true
		print("Todos os dados prontos! Total de palavras: ", array_palavras.size())
	else:
		print("ERRO: Não foi possível encontrar o arquivo res://data/palavras.json")
