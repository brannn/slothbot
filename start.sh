#!/bin/sh
#
# Daemontools-like wrapper for the MUC bot
#

exec > /tmp/slothbot.log
exec 2>&1

while :
do
        ruby slothbot.rb
        sleep 5
done

