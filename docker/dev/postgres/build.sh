#!/bin/bash

BUILD='docker build -t dev/postgres:9.5.6 .'

echo
echo "<Postgres> $BUILD"
echo

$BUILD
