#!/bin/bash

BUILD='docker build -t dev/redis:3.2.8 .'

echo
echo "<Redis> $BUILD"
echo

$BUILD
