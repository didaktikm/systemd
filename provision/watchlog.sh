#!/bin/env bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
   logger "$DATE  Houston, we have a problem!"
else
   exit 0
fi