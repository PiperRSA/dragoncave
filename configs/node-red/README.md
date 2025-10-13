# Node-RED Data Directory

This directory is mounted into the Node-RED container at `/data`. It stores flows, credentials, and user settings.

Create it on the Raspberry Pi with:

```bash
sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/node-red
```

To migrate flows, copy exported `.json` files here before redeploying `stacks/flows-node-red.yml`.
