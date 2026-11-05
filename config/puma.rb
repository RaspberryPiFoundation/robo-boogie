# frozen_string_literal: true

# A single process is plenty for this app; RoboBoogie.db sizes its pool to match.
threads_count = Integer(ENV.fetch("PUMA_MAX_THREADS", "5"))
threads threads_count, threads_count

port Integer(ENV.fetch("PORT", "9292"))
environment ENV.fetch("RACK_ENV", "development")
