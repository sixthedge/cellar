#!/bin/bash

BUILD='docker build -t prod/postgres:9.5.6 .'

echo
echo "<Postgres> $BUILD"
echo

$BUILD
