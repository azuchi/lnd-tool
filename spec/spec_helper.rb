# frozen_string_literal: true

require 'lnd/tool'
require 'tmpdir'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def random_db_path
  Pathname.new(File.expand_path("#{Dir.tmpdir}/lnd-tool-#{rand(10_000)}")).to_s
end

