require "bundler/gem_tasks"

desc "Load the gem into an irb console"
task :console do
  require 'irb'
  ARGV.clear
  ARGV.push("-Ilib")
  ARGV.push("-rdotmailer")
  IRB.start
end
