#!/bin/bash

BUILD='docker build -t base/oauth/gems:5.0.1 .'

echo
echo "<Rails> $BUILD"
echo

$BUILD
