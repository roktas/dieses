# frozen_string_literal: true

require 'rake/clean'

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

desc 'Lint code'
task lint: :rubocop

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.test_files = FileList['test/client/**/*.rb', 'test/server/**/*.rb']
end

task :test do # rubocop:disable Rake/Desc
  warn ''
  warn 'Running integration tests'
  warn ''
  sh '.local/bin/test'
end

require 'rubygems/tasks'
Gem::Tasks.new console: false do |tasks|
  tasks.push.host = ENV['RUBYGEMS_HOST'] || Gem::DEFAULT_HOST
end

CLEAN.include('*.gem', 'pkg')

if Dir.exist? 'man'
  desc 'Generate manual pages'
  task :man do
    sh 'cd man/tr && ronn *.ronn' if Dir.exist? 'man/tr'
    sh 'cd man/en && ronn *.ronn' if Dir.exist? 'man/en'
  end
  CLEAN.include('man/**/*[0-9].html')
  CLOBBER.include('man/**/*.[0-9]')
else
  task :man  # rubocop:disable Rake/DuplicateTask
end

task default: %i[lint test]
