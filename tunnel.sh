#!/bin/bash

DIR=~/.ssh/tunnels
CNF="$DIR/config"

LB_CNF=$(echo "$CNF" | sed "s|${HOME}/|~/|g")

if [ ! -f $CNF ]; then
  echo "$LB_CNF no encontrado"
  exit 1
fi

TNLS=($(grep -ohE "^(\S+): " ~/.ssh/tunnels/config | cut -d':' -f1 | sort))
TNLS=$(printf ", %s" "${TNLS[@]}")
TNLS=${TNLS:2}

if [ -z "$1" ]; then
  echo "Debe pasar como argumento un nombre de tunel registrado en $LB_CNF"
  if [ ! -z "$TNLS" ]; then
    echo "Tuneles disponibles: $TNLS"
  fi
  exit 1
fi

TN="$1"
LN=$(grep "^${TN}: " "$CNF")

if [ -z "$LN" ]; then
  echo "$TN no encontrado en $LB_CNF"
  if [ ! -z "$TNLS" ]; then
    echo "Tuneles disponibles: $TNLS"
  fi
  exit 1
fi

exe() {
  CM=$(echo "$@" | sed "s|${HOME}/|~/|g")
  echo "\$ $CM"
  "$@"
}

LN=$(echo "${LN#*: }" | sed 's/\s\s*/ /g' | sed 's/^\s*|\s*$//g')
TG=$(echo "$LN" | rev | cut -d' ' -f1 | rev)

CNT="$DIR/$TN.control"
if [ -e "$CNT" ]; then
  echo "# $TN va a ser finalizado"
  exe ssh -S "$CNT" -O exit $TG
else
  echo "# $TN va a ser iniciado"
  exe ssh -M -S "$CNT" $LN
fi
