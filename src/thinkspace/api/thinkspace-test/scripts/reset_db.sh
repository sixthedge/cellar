#!/bin/bash
set -e

export APP_DB_HOST=localhost
export APP_DB_NAME=ts_development
export APP_DB_USERNAME=postgres
export APP_DB_PASSWORD=password

rails db:environment:set RAILS_ENV=test
rails totem:db:reset[none] RAILS_ENV=test
