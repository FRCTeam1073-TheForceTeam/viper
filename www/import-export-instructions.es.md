Instrucciones de Importación y Exportación
========================

## Memoria USB

La transferencia de datos de exploración a otro sistema de exploración se puede hacer con una memoria USB.

1. Conecta una laptop a la ethernet del sistema de exploración (o a uno de los adaptadores de red USB-C).
2. Conecta la memoria USB a la laptop.
3. Abre la página de exploración en el navegador web de la laptop: **`$URL$`**
4. Desde la página de inicio, haz clic en el evento.
5. Desplázate al final de la columna izquierda y haz clic en "Exportar todos los datos del evento"
6. Haz clic en el enlace "Descargar".
7. Guarda el archivo `.json` en la memoria USB.
8. Extrae la memoria USB de la laptop.
9. Lleva la memoria USB a un dispositivo en el otro sistema de exploración y conéctala.
10. Abre la aplicación de exploración en el navegador web allí.
11. Desde la página de inicio, haz clic en "+ Añadir un evento"
12. Desde la sección "Importación" haz clic en "Examinar..."
13. Selecciona el archivo `.json` de la memoria USB y ábrelo.
14. Verás la pantalla del evento con los datos recién importados.

## Red

La transferencia de datos del evento cuando ambos sistemas de exploración están conectados a internet se puede hacer desde un navegador único que pueda acceder a ambos sistemas.

1. En tu navegador web, ve al evento que deseas exportar (de donde deseas transferir los datos).
2. Haz clic en el enlace "Exportar todos los datos del evento" al final de la columna izquierda.
3. En "Transferir Evento", escribe el nombre de host del otro sistema. Para un sistema de exploración que se ejecuta localmente, probablemente será "localhost" o con un número de puerto como "localhost:8080".
4. Presiona el botón "Transferir".
5. Verás la pantalla del evento con los datos recién importados.
