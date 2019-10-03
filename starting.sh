#!/bin/bash

DOMAIN="*:4444"
DIR=`pwd`

APPNAME="freee"
SCRIPT="script/freee"
PIDFILE="/tmp/$APPNAME.pid"

PID=`ps -aef | grep "script/$APPNAME" | grep -v grep | awk '{print $2}'`

startme() {
    if [ -n "$PID" ]
        then
            echo "Service already working"
        else
            cd $DIR
            echo "Starting "script/$APPNAME" daemon at $DOMAIN"
            perl /usr/local/bin/morbo $SCRIPT reload --listen http://$DOMAIN > /dev/null 2>&1 &

            STARTPID=`ps -aef | grep "script/$APPNAME" | grep -v grep | awk '{print $2}'`
            echo $STARTPID > $PIDFILE
    fi
}

stopme() {
    if [ -n "$PID" ]
        then
            kill -9 $PID
            echo "Service stoppped"
        else
            echo "Service not starting"
    fi

    if [ -f ${PIDFILE} ]
        then
            rm $PIDFILE
    fi
}

restartme() {
    if [ -n "$PID" ]
        then
            kill -9 $PID
            echo "Service stoppped"
        else
            echo "Service not starting"
    fi

    if [ -f ${PIDFILE} ]
        then
            rm $PIDFILE
    fi

    cd $DIR
    echo "Starting "script/$APPNAME" daemon at $DOMAIN"
    perl /usr/local/bin/morbo $SCRIPT reload --listen http://$DOMAIN > /dev/null 2>&1 &

    NEWPID=`ps -aef | grep "script/$APPNAME" | grep -v grep | awk '{print $2}'`
    if [ -n "$NEWPID" ]
        then
            echo "Service started successfully"
            echo $NEWPID > $PIDFILE
        else
            echo "Service not starting"
    fi
}

case "$1" in 
    start)   startme ;;
    stop)    stopme ;;
    restart) restartme ;;
    *) echo "usage: $0 start|stop|restart" >&2
       exit 1
       ;;
esac

# 		perl /usr/local/bin/morbo script/freee reload --listen http://*:4444 > /dev/null 2>&1 &
