## Instruções de Escutismo

Observe o seu robô e registe as suas ações clicando nos botões correspondentes. Os ícones utilizados para ações são:

| | Coletar | Remover<br>(sem<br>recolher) | Solte<br>ou perca | Lugar<br>ou Pontuação | Sair | Subir |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Coral** | <img src=coral-collect.png style=height:5em> | | <img src=coral-drop.png style=height:5em> | <img src=coral-place.png style=height:5em> | | |
| **Algas** | <img src=algae-collect.png style=height:5em> | <img src=algae-remove.png style=height:5em> | <img src=algae-drop.png style=height:5em> | <img src=algae-place.png style=height:5em> | | |
| **Robô** | | | | | <img src=leave.png style=height:5em> | <img src=climb.png style=height:5em> |

Assim que o seu bot colocar algas no processador, é responsável por registar se o **jogador humano do adversário** lança essas algas para a sua rede de barcaça.

A maioria dos botões na imagem do campo são colocados onde a ação ocorre, mas existem exceções:

- O botão Soltar (<img src=coral-drop.png style=height:1em> e <img src=algae-drop.png style=height:1em>) aparece **na borda do campo**, mas deve ser utilizado sempre que uma peça do jogo é **largada em qualquer lugar**.
- Em automático, a saída da linha de partida (<img src=leave.png style=height:1em>) deve ser pressionada quando o robô sai da linha de partida de qualquer posição.
- No telop, os botões de recolha (<img src=coral-collect.png style=height:1em> e <img src=algae-collect.png style=height:1em>) **no tapete** devem ser utilizados para **qualquer recolha no solo**, independentemente da localização.
- No telop, os botões de recolha (<img src=coral-collect.png style=height:1em> e <img src=algae-collect.png style=height:1em>) **do outro lado do campo** devem ser utilizados para **qualquer recolha no outro lado do campo**, no solo ou não.

O botão de subida (<img src=climb.png style=height:1em>) inicia um temporizador que irá adicionar continuamente segundos ao tempo de subida. Pressiona o botão uma segunda vez quando o robô sair do chão com sucesso, quando desistir ou quando a partida terminar.

### Estrutura de correspondência
O Scouting de cada partida está dividido em quatro períodos:
- **Pré-jogo** — Antes do início da partida.
- **Trabalhador independente** — O robô atua de forma independente, sem intervenção de jogadores humanos.
- **Teleoperado** — O robô é controlado por controlo remoto.
- **Fim do jogo** — O robô tenta subir para jaulas ou estacionar debaixo da barcaça.

Certifique-se de mudar para teleop quando o modo automático terminar. Esquecer-se de mudar para teleop é um erro comum de reconhecimento. O botão para prosseguir para teleop começará a piscar <span style=color:red>vermelho</span> e <span style=color:blue>azul</span> para o recordar.

### Guardar os seus dados

Utilize um dos botões na parte inferior para guardar os dados quando terminar. O botão sugerido será ampliado – normalmente este será o botão para avançar para a próxima partida, mas em certos casos a aplicação recomendará que carregue os seus dados para o centro de observação. Se não tiver uma rede sem fios, terá de ligar o seu dispositivo ao hub para fazer o upload dos seus dados.
