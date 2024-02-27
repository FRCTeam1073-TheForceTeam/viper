Import Export Instructions
========================

## USB Stick

Transferring scouting data to another scouting system can be done with a USB stick.

1. Plug a laptop into the scouting system ethernet (or one of the USB-C network dongles).
2. Plug the USB stick into the laptop.
3. Open the scouting page in the laptop's web browser: **`$URL$`**
4. From the home page, click to the event.
5. Scroll to the bottom of the left column and click "Export all event data"
6. Click the "Download" link.
7. Save the `.json` file to the USB stick.
8. Remove the USB stick from the laptop.
9. Take the USB stick to a device on the other scouting system and plug it in.
10. Open the scouting app in the web browser there.
11. From the home page, click "+ Add an event"
12. From the "Import" section click "Browse..."
13. Select the `.json` file from the USB stick and open it.
14. You will see the event screen with the newly imported data.

## Network

Transferring event data when the two scouting systems are both connected to the internet can be done from a single browser that can access both systems.

1. In your web browser, go to the event that you want to export (where you want to transfer the data FROM.)
2. Click on the "Export all event data" link at the bottom of the left column.
3. Under "Transfer Event", type the host name of the other system. For a locally running scouting system this will probably be "localhost" or with a port number like "localhost:8080".
4. Hit the "Transfer" button.
5. You will see the event screen with the newly imported data.
