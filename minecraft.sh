#!/bin/bash
#---------------------------------------------------------------------
# Script: minecraft.sh
# Version: 1.0
# Description: Start/Stop Script for Minecraft/Craftbuckkit
# ---------------------------------------------------------------------
#   __  __ _                            __ _   
#  |  \/  (_)                          / _| |  
#  | \  / |_ _ __   ___  ___ _ __ __ _| |_| |_ 
#  | |\/| | | '_ \ / _ \/ __| '__/ _` |  _| __|
#  | |  | | | | | |  __/ (__| | | (_| | | | |_ 
#  |_|  |_|_|_| |_|\___|\___|_|  \__,_|_|  \__|
#                                                                                      
# Usage:
# 1) Upload this script
# 2) Edit the general settings
# 3) chown a+x minecraft.sh
# 4) ./minecraft.sh {status|start|stop|restart|save|backup}

# General settings
USERNAME='minecraft'
MCPATH='/home/minecraft/'
MINRAM='2048M'
MAXRAM='3072M'
MCFILENAME='craftbukkit-1.15.2.jar'
BACKUPPATH='/backup/data'


############################################### MAIN ##############################################################
START="java -Xms$MINRAM -Xmx$MAXRAM -jar $MCFILENAME"
ME=`whoami`

with_user() {
  if [ "$ME" == "$USERNAME" ] ; then
    bash -c "$1"
  else
    su - $USERNAME -c "$1"
  fi
}

status() {
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $MCFILENAME > /dev/null
    then
      echo "Server run"
    else
      echo "Server don't run"
    fi
}

start() {
  if ps ax | grep -v grep | grep -v -i SCREEN | grep $MCFILENAME > /dev/null
  then
    echo "Server already up."
  else
    echo "Server is starting"
    with_user "cd $MCPATH && screen -AmdS minecraft $START"
    sleep 10
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $MCFILENAME > /dev/null
    then
      echo "Server is now running."
    else
      echo "Server could not be started."
    fi
  fi
}

stop() {
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $MCFILENAME > /dev/null
    then
        echo "Shutdown minecraft server"
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"say The Minecraftserver will shutdown in 10 seconds.\"\015'"
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"save-all\"\015'"
        sleep 10
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"stop\"\015'"
        sleep 20
    else
        echo "Minecraft don't run."
        exit
    fi
    
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $MCFILENAME > /dev/null
    then
        echo "Server could not be shutdown, server is still running."
    else
        echo "Minecraftserver is down."
    fi
}

saveoff() {
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $MCFILENAME > /dev/null
	then
		echo "Server läuft, suspending für saves"
		with_user "screen -p 0 -S minecraft -X eval 'stuff \"say SERVER wird gespeichert, nur lesezugriff möglich.\"\015'"
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"save-off\"\015'"
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"save-all\"\015'"
        sync
		sleep 15
	else
        echo "Minecraft don't run."
	fi
}

saveon() {
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $MCFILENAME > /dev/null
	then
		echo "Autosave is enabled"
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"save-on\"\015'"
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"say SERVER wurde gespeichert,\"\015'"
	    with_user "screen -p 0 -S minecraft -X eval 'stuff \"say schreib und lesezugriff möglich.\"\015'"
	else
        echo "Minecraft don't run."
	fi
}

backup() {
   echo "Start backup of minecraft server."

    if [ ! -d $BACKUPPATH/`date '+%Y-%m'`/minecraft_`date "+%d.%m.%Y"` ]
    then
        with_user "mkdir -p $BACKUPPATH/`date '+%Y-%m'`/minecraft_`date "+%d.%m.%Y"`"
    fi

    if [ -d $BACKUPPATH/`date '+%Y-%m'`/minecraft_`date "+%d.%m.%Y"` ]
    then
        with_user "cd $BACKUPPATH/`date '+%Y-%m'`/minecraft_`date "+%d.%m.%Y"` && tar cfvz minecraft_backup_`date +"%Y-%m-%d"`.tar.gz $MCPATH* && cd -"  
    fi
   
   echo "Backup successfully created"
}

save() {
    echo "Save the world of minecraft."
    if ps ax | grep -v grep | grep -v -i SCREEN | grep $MCFILENAME > /dev/null
    then
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"say Map will be saved....\"\015'"
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"save-all\"\015'"
        with_user "screen -p 0 -S minecraft -X eval 'stuff \"say Map has been saved.\"\015'"
    else
        echo "Minecraft don't run."
    fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  save)
    save
    ;;
  backup)
    stop
    backup
    start
    ;;
  status)
    status
    ;;
  *)
  echo "Usage: service minecraft {status|start|stop|restart|save|backup}"
  exit 1
  ;;
esac

exit 0
