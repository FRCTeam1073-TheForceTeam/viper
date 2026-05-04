## Instrucciones de Scouting

Observa tu robot y registra sus acciones haciendo clic en los botones correspondientes. Los iconos utilizados para las acciones son:

| | Recolectar | Remover<br>(sin<br>recolectar) | Soltar<br>o Fallar | Colocar<br>o Anotar | Salir | Escalar |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Coral** | <img src=coral-collect.png style=height:5em> | | <img src=coral-drop.png style=height:5em> | <img src=coral-place.png style=height:5em> | | |
| **Alga** | <img src=algae-collect.png style=height:5em> | <img src=algae-remove.png style=height:5em> | <img src=algae-drop.png style=height:5em> | <img src=algae-place.png style=height:5em> | | |
| **Robot** | | | | | <img src=leave.png style=height:5em> | <img src=climb.png style=height:5em> |

Después de que tu bot coloque alga en el procesador, eres responsable de registrar si el **jugador humano del oponente** lanza ese alga a la red de carga de su equipo.

La mayoría de los botones en la imagen del campo se colocan donde tiene lugar esa acción, pero hay excepciones:

- El botón de soltar (<img src=coral-drop.png style=height:1em> y <img src=algae-drop.png style=height:1em>) aparece **en el borde del campo** pero está destinado a usarse cuando se suelta una pieza de juego **en cualquier lugar**.
- En auto, salir de la línea de salida (<img src=leave.png style=height:1em>) debe presionarse cuando el robot sale de la línea de salida desde cualquier posición.
- En teleoperado, los botones de recolección (<img src=coral-collect.png style=height:1em> y <img src=algae-collect.png style=height:1em>) **en la alfombra** están destinados a usarse para **cualquier recogida del suelo**, independientemente de la ubicación.
- En teleoperado, los botones de recolección (<img src=coral-collect.png style=height:1em> y <img src=algae-collect.png style=height:1em>) **en el otro lado del campo** están destinados a usarse para **cualquier recogida en el otro lado del campo**, entre otras cosas.

El botón de escalada (<img src=climb.png style=height:1em>) inicia un temporizador que continuamente suma segundos al tiempo de escalada. Presiona el botón una segunda vez cuando el robot se separa exitosamente del suelo, cuando se rinde, o cuando termina el partido.

### Estructura del Partido
El escaneo de cada partido se divide en cuatro períodos:
 - **Pre-partido** — Antes de que el partido haya comenzado.
 - **Autónomo** — El robot actúa independientemente sin entrada de jugadores humanos.
 - **Teleoperado** — El robot es controlado mediante control remoto.
 - **Juego final** — El robot intenta escalar en jaulas o estacionar bajo la carga.

Asegúrate de cambiar a teleoperado cuando termina auto. Olvidar cambiar a teleoperado es un error común de escaneo. El botón para proceder a teleoperado comenzará a parpadear <span style=color:red>rojo</span> y <span style=color:blue>azul</span> para recordarte.

### Guardando Tus Datos

Usa uno de los botones en la parte inferior para guardar los datos cuando termines. El botón sugerido será más grande — generalmente será el botón para avanzar al siguiente partido, pero en ciertos casos la aplicación recomendará que cargues tus datos al centro de scouting. Si no estás en una red inalámbrica, necesitarás enchufar tu dispositivo al hub para subir tus datos.
