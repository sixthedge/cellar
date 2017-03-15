#!/bin/bash

BUILD='docker build -t ember-cli/base:2.10.1 .'

echo
echo "<Ember-cli> $BUILD"
echo

$BUILD
