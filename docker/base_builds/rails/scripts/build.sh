#!/bin/bash

BUILD='docker build -t base/rails/gems/scripts:5.0.1 .'

echo
echo "<Rails> $BUILD"
echo

$BUILD
