#!/bin/bash

BUILD='docker build -t dev/rails:5.0.1 .'

echo
echo "<Rails> $BUILD"
echo

$BUILD
