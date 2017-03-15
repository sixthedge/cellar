#!/bin/bash

BUILD='docker build -t dev/socketio:1.7.3 .'

echo
echo "<Socket.io> $BUILD"
echo

$BUILD
