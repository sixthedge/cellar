#!/bin/bash

BUILD='docker build -t prod/redis:3.2.8 .'

echo
echo "<Redis> $BUILD"
echo

$BUILD
