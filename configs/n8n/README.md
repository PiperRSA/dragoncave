# n8n Data Directory

This directory mounts to `/home/node/.n8n` in the n8n container. It persists workflows, credentials, and runtime state.

Create it on the Raspberry Pi before deployment:

```bash
sudo install -d -m 0755 -o 1000 -g 1000 /opt/dragoncave/configs/n8n
```

Encrypt sensitive credentials using n8n's built-in encryption keys and back up this folder with the rest of `/opt/dragoncave/configs`.
