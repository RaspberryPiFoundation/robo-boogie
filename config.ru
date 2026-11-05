# frozen_string_literal: true

require_relative "app"
require_relative "lib/robo_boogie/force_https"

use RoboBoogie::ForceHTTPS if ENV["RACK_ENV"] == "production"

# Connect at boot so a missing or bad DATABASE_URL fails the deploy, not the first request.
RoboBoogie.db

run RoboBoogie::App
