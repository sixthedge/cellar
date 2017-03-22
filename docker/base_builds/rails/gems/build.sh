#!/bin/bash

BUILD='docker build -t base/rails/gems:5.0.1 .'

echo
echo "<Rails> $BUILD"
echo

$BUILD
