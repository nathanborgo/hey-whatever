require './application'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end

desc "Reset taco cached counters"
task :reset_counters do
  User.all.each { |user| User.reset_counters(user.id, :tacos) }
end

