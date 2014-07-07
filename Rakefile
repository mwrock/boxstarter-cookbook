require 'rspec/core/rake_task'
require 'foodcritic'
#require 'kitchen'

desc 'Run Chef style checks'
FoodCritic::Rake::LintTask.new(:chef) do |t|
  t.options = {
    fail_tags: ['any']
  }
end

desc "Run ChefSpec examples"
RSpec::Core::RakeTask.new(:spec)

task default: ['chef', 'spec']