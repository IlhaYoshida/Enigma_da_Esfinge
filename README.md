# Enigma da Esfinge - Jogo de Alfabetização

O Enigma da Esfinge é um jogo educativo de alfabetização desenvolvido para a plataforma NinoEdu. O jogo utiliza uma temática do Antigo Egito para auxiliar crianças no processo de formação de palavras através da consciência silábica.

## Objetivo do Projeto
Desenvolver uma ferramenta interativa e lúdica para o ecossistema NinoEdu, focada em tornar o aprendizado de sílabas uma experiência recompensadora e visualmente estimulante para crianças em fase de alfabetização.

## Contribuição Pedagógica
O jogo trabalha pilares essenciais da alfabetização:

* Consciência Silábica: Identificação e manipulação das unidades sonoras que formam as palavras.
* Associação Semântica: Relação direta entre a imagem do objeto e sua representação escrita.
* Análise e Síntese: Capacidade de decompor a palavra em sílabas e montá-la novamente nos espaços correspondentes.
* Feedback Imediato: O sistema de acertos e erros permite que a criança aprenda com a tentativa e erro de forma lúdica.

## Como Jogar (Tutorial)
A Esfinge desafia você a decifrar as palavras! Veja como jogar:

1. Observe a Imagem: No centro do painel, uma imagem aparecerá.
2. Arraste as Sílabas: Na parte inferior da tela, você verá várias sílabas. Clique e arraste as sílabas corretas para os slots abaixo da imagem.
3. Vença o Desafio:
	* Se completar a palavra corretamente, você ganha um Check Verde no canto da tela.
	* Se errar alguma sílaba, você recebe um X Vermelho.
4. Condições de Vitória e Derrota:
	* Vencer: Consiga 3 Checks Verdes para ganhar o jogo.
	* Perder: Se acumular 3 X Vermelhos, você perde a partida.

## Estrutura de Pastas
A organização interna do projeto segue o padrão abaixo:

```text
res://
├── assets/             # Recursos visuais e sonoros
│   ├── esfinge/        # Sprites e animações da personagem
│   ├── fundo/          # Imagens de ambiente (ex: deserto.jpg)
│   ├── ui/             # Elementos da interface de usuário
│   ├── IntroNinoEdu.ogv # Vídeo de introdução da plataforma
│   └── musica.mp3      # Trilha sonora do jogo
├── scenes/             # Cenas do jogo (Menu, Jogo Principal, Telas de Fim)
└── scripts/            # Lógica de programação e banco de dados de palavras
