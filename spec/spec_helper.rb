# frozen_string_literal: true

require "jekyll"
require File.expand_path("../lib/jekyll-compose.rb", __dir__)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = "doc" if config.files_to_run.one?

  config.profile_examples = 3

  config.order = :random

  Kernel.srand config.seed

  Jekyll.logger.log_level = :error

  ###
  ### Helper methods
  ###
  TEST_DIR = __dir__
  def test_dir(*files)
    File.expand_path(File.join(TEST_DIR, *files))
  end

  def source_dir(*files)
    test_dir("source", *files)
  end

  def fixture_site
    Jekyll::Site.new(Jekyll::Utils.deep_merge_hashes(
                       Jekyll::Configuration::DEFAULTS,
                       "source" => source_dir, "destination" => test_dir("dest")
                     ))
  end

  def capture_stdout(level = :debug)
    buffer = StringIO.new
    Jekyll.logger = Logger.new(buffer)
    Jekyll.logger.log_level = level
    yield
    buffer.rewind
    buffer.string.to_s
  ensure
    Jekyll.logger = Logger.new(StringIO.new, :error)
  end
end
