# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'dieses/version'

Gem::Specification.new do |s| # rubocop:disable Metrics/BlockLength
  s.name        = 'dieses'
  s.author      = 'Recai Oktaş'
  s.email       = 'roktas@gmail.com'
  s.license     = 'GPL-3.0-or-later'
  s.version     = Dieses::VERSION.dup
  s.summary     = 'Guide sheets generator for penmanship, calligraphy, lettering, and sketching'
  s.description = 'Guide sheets generator for penmanship, calligraphy, lettering, and sketching'

  s.homepage      = 'https://alaturka.github.io/dieses'
  s.files         = Dir['CHANGELOG.md', 'LICENSE.md', 'README.md', 'BENİOKU.md', 'dieses.gemspec', 'lib/**/*']
  s.executables   = %w[diesis dieses]
  s.require_paths = %w[lib]

  s.metadata['changelog_uri']     = 'https://github.com/alaturka/dieses/blob/master/CHANGELOG.md'
  s.metadata['source_code_uri']   = 'https://github.com/alaturka/dieses'
  s.metadata['bug_tracker_uri']   = 'https://github.com/alaturka/dieses/issues'

  s.required_ruby_version = '>= 2.7.0' # rubocop:disable Gemspec/RequiredRubyVersion

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest-focus', '>= 1.2.1'
  s.add_development_dependency 'minitest-reporters', '>= 1.4.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-minitest'
  s.add_development_dependency 'rubocop-performance'
  s.add_development_dependency 'rubocop-rake'
  s.add_development_dependency 'rubygems-tasks'
  s.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
