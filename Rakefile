require 'rspec/core/rake_task'
require 'foodcritic'
require 'kitchen/rake_tasks'

desc 'Run Chef style checks'
FoodCritic::Rake::LintTask.new(:chef) do |t|
  t.options = {
    fail_tags: ['any']
  }
end

Kitchen::RakeTasks.new

desc "Run ChefSpec examples"
RSpec::Core::RakeTask.new(:spec)

task default: ['chef', 'spec']
