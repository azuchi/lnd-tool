# frozen_string_literal: true

require_relative 'lib/lnd/tool/version'

Gem::Specification.new do |spec|
  spec.name          = 'lnd-tool'
  spec.version       = LND::Tool::VERSION
  spec.authors       = ['azuchi']
  spec.email         = ['azuchi@chaintope.com']

  spec.summary       = 'LND Tool - Ruby tools for LND'
  spec.description   = 'LND Tool - Ruby tools for LND'
  spec.homepage      = 'https://github.com/azuchi/lnd-tool'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'lnrpc', '~> 0.13.0'
  spec.add_dependency 'thor', '~> 1.1.0'

  spec.add_development_dependency 'rspec', '~> 3.0'

end
