# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

namespace :db do
  desc "Apply database migrations (runs in Heroku's release phase)"
  task :migrate do
    require_relative "lib/robo_boogie/db"
    Sequel.extension :migration
    Sequel::Migrator.run(RoboBoogie.db, File.expand_path("db/migrate", __dir__))
    puts "Database is up to date"
  end
end

task default: :test
