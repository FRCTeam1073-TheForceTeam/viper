Instruções de importação e exportação
========================

## Pendrive USB

A transferência dos dados de aferição para outro sistema de aferição pode ser feita com uma pen USB.

1. Ligue um computador portátil à Ethernet do sistema de reconhecimento (ou a um dos dongles de rede USB-C).
2. Ligue o pendrive ao portátil.
3.º Abra a página de observação no browser do portátil: **`$URL$`**
4.Na página inicial, clique no evento.
5.º Desça até ao final da coluna esquerda e clique em “Exportar todos os dados do evento”
6.º Clique no link "Descarregar".
7.º Guarde o ficheiro `. json` no pendrive.
8.º Remova o pendrive do portátil.
9.º Leve o pendrive USB a um dispositivo no outro sistema de observação e ligue-o.
10.º Abra a aplicação de reconhecimento no navegador da Web.
11.Na página inicial, clique em "+ Adicionar um evento"
12.Na secção "Importar", clique em "Navegar..."
13.º Selecione o ficheiro `. json` do pendrive e abra-o.
14.º Verá o ecrã do evento com os dados recém-importados.

## Rede

A transferência de dados de eventos quando os dois sistemas de observação estão ligados à Internet pode ser feita a partir de um único browser que pode aceder a ambos os sistemas.

1.No seu browser, desloque-se até ao evento que pretende exportar (de onde pretende transferir os dados).
2.º Clique na ligação “Exportar todos os dados do evento” na parte inferior da coluna esquerda.
3.º Em "Transfer Event", introduza o nome do host do outro sistema. Para um sistema de reconhecimento executado localmente, será provavelmente "localhost" ou com um número de porta como "localhost:8080".
4.º Clique no botão "Transferir".
5.º Verá o ecrã do evento com os dados recém-importados.
