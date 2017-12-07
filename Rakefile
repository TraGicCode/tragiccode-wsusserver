require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'metadata-json-lint/rake_task'
require 'puppet-strings/tasks'
require "guard/rake_task"
require 'github_changelog_generator/task'
require 'puppet_blacksmith/rake_tasks'



Guard::RakeTask.new(:guard)

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.relative = true
PuppetLint.configuration.ignore_paths = ['spec/**/*.pp', 'pkg/**/*.pp']

desc 'Validate manifests, templates, and ruby files'
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb', 'lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ %r{spec/fixtures}
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

desc 'Run metadata_lint, lint, validate, and spec tests.'
task :test do
  [:metadata_lint, :lint, :validate, :spec].each do |test|
    Rake::Task[test].invoke
  end
end

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  metadata_json = File.join(File.dirname(__FILE__), 'metadata.json')
  metadata = JSON.load(File.read(metadata_json))
  config.future_release = "v#{metadata['version']}" if metadata['version'] =~ /^\d+\.\d+.\d+$/
  config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file.\nThis project follows semver to help clients understand the impact of updates/changes.  Find out more at http://semver.org."
  config.project = metadata['name']
end