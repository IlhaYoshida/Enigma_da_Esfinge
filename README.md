# Enigma da Esfinge - Jogo de Alfabetização

O Enigma da Esfinge é um jogo educativo de alfabetização desenvolvido para a plataforma NinoEdu. O jogo utiliza uma temática do Antigo Egito para auxiliar crianças no processo de formação de palavras através da consciência silábica, incluindo crianças com deficiência intelectual.

## Jogue Agora

* **Versão Web (navegador):** [ilhayoshida.github.io/Enigma_da_Esfinge](https://ilhayoshida.github.io/Enigma_da_Esfinge/)
* **Versão Android (APK):** disponível na seção [Releases](https://github.com/IlhaYoshida/Enigma_da_Esfinge/releases/latest) deste repositório.

## Objetivo do Projeto
Desenvolver uma ferramenta interativa e lúdica para o ecossistema NinoEdu, focada em tornar o aprendizado de sílabas uma experiência recompensadora e visualmente estimulante para crianças em fase de alfabetização, com atenção especial à acessibilidade para crianças com deficiência intelectual.

## Contribuição Pedagógica
O jogo trabalha pilares essenciais da alfabetização:

* Consciência Silábica: Identificação e manipulação das unidades sonoras que formam as palavras.
* Associação Semântica: Relação direta entre a imagem do objeto e sua representação escrita.
* Análise e Síntese: Capacidade de decompor a palavra em sílabas e montá-la novamente nos espaços correspondentes.
* Feedback Imediato: O sistema de acertos e erros permite que a criança aprenda com a tentativa e erro de forma lúdica.

## Tutorial Dentro do Jogo
Ao pressionar "Jogar", um tutorial narrado por voz é exibido automaticamente antes da primeira rodada, mostrando a própria jogabilidade (sem depender de leitura de texto, pensando em crianças que ainda não leem):

1. Apresentação da imagem que a criança precisa decifrar.
2. Onde encontrar as sílabas disponíveis.
3. Demonstração de um erro (sílaba errada arrastada até o quadrado).
4. Demonstração de um acerto (sílaba certa arrastada até o quadrado).
5. Explicação do placar de acertos e erros.

O tutorial pode ser pulado a qualquer momento pelo botão de pular, e não trava o jogo caso o áudio não termine de tocar por algum motivo.

## Como Jogar
A Esfinge desafia você a decifrar as palavras! Veja como jogar:

1. Observe a Imagem: No centro do painel, uma imagem aparecerá.
2. Ouça as Sílabas: Passe o mouse sobre cada sílaba, na parte inferior da tela, para ouvir como ela soa.
3. Arraste as Sílabas: Clique e arraste as sílabas corretas para os slots abaixo da imagem, na ordem certa.
4. Vença o Desafio:
    * Se completar a palavra corretamente, você ganha um Check Verde no canto da tela.
    * Se errar alguma sílaba, você recebe um X Vermelho.
5. Condições de Vitória e Derrota:
    * Vencer: Consiga 3 Checks Verdes para ganhar o jogo.
    * Perder: Se acumular 3 X Vermelhos, você perde a partida.

## Estrutura de Pastas
A organização interna do projeto segue o padrão abaixo:

```text
res://
├── assets/                # Recursos visuais e sonoros
│   ├── audio/tutorial/    # Falas narradas do tutorial (7 áudios)
│   ├── audios_api/        # Áudios das sílabas e das palavras
│   ├── esfinge/           # Sprites e animações da personagem
│   ├── fundo/             # Imagens de ambiente (ex: deserto.jpg)
│   ├── imagens_api/       # Imagens das palavras do jogo
│   ├── tutorial/          # Cursor e ícone de pular usados no tutorial
│   ├── ui/                # Elementos da interface (menu, volume, etc.)
│   ├── IntroNinoEdu.ogv   # Vídeo de introdução da plataforma
│   └── musica.mp3         # Trilha sonora do jogo
├── data/
│   └── palavras.json      # Banco de palavras, sílabas e imagens do jogo
├── scenes/                # Cenas do jogo (Menu, Jogo Principal, Telas de Fim, Barra Lateral)
└── scripts/               # Lógica de programação (jogo, tutorial, menu, etc.)
```

A pasta `Exportacao/` (export web) e `build/` (APKs gerados localmente) não fazem parte do controle de versão da branch principal — a versão web publicada vive na branch `jogo-web` (usada pelo GitHub Pages) e os APKs são publicados em [Releases](https://github.com/IlhaYoshida/Enigma_da_Esfinge/releases).

## Rodando o Projeto Localmente
1. Instale o [Godot Engine 4.6](https://godotengine.org/download) (ou mais recente compatível).
2. Abra o Godot e importe a pasta deste repositório como projeto (`project.godot`).
3. Pressione o botão de "Play" (F5) para rodar o jogo.

Para gerar seu próprio APK, use **Project > Export** com o preset "Android" já configurado no projeto (é necessário ter o Android SDK, o Java JDK e os Export Templates do Godot instalados — veja a [documentação oficial do Godot sobre exportação Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)).
