# frozen_string_literal: true

require "sequel"

module RoboBoogie
  Sequel.default_timezone = :utc

  # One pool per process, sized to Puma's thread count.
  def self.db
    @db ||= Sequel.connect(
      ENV.fetch("DATABASE_URL"),
      max_connections: Integer(ENV.fetch("PUMA_MAX_THREADS", "5"))
    ).tap { |db| db.extension(:connection_validator) }
  end
end
