#!/bin/bash

BUILD='docker build -t dev/sio:1.7.3 .'

echo
echo "<Socket.io> $BUILD"
echo

$BUILD
