# General
A start/stop/backup script for a craftbukkit/minecraft server.

# Usage
 1) Upload this script
 2) Edit the general settings
 3) Set permissions
 ```bash
 chmod a+x minecraft.sh
  ```
 4) Usage
  ```bash
  ./minecraft.sh {status|start|stop|restart|save|backup}
```

# Create cron for a backup routine

1) Edit the crontab
```bash
  crontab -e
```
2) Add linw for (every day at 1am)
```bash
0 1 * * * /path/to/minecraft.sh backup >> /var/log/minecraft_backup.log 2>&1
```