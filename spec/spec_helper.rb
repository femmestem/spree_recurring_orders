require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_group  'Controllers', 'app/controllers'
  add_group  'Models', 'app/models'
  add_group  'Overrides', 'app/overrides'
  add_group  'Libraries', 'lib'
end

ENV['RAILS_ENV'] ||= 'test'

begin
  require File.expand_path('../dummy/config/environment', __FILE__)
rescue LoadError
  puts 'Could not load dummy application. Please ensure you have run `bundle exec rake test_app`'
  exit
end

require 'factory_girl'
require 'rspec/rails'
require 'ffaker'
require 'pry'
require "spree/testing_support/factories"
require 'spree/testing_support/preferences'
require 'spree/testing_support/shoulda_matcher_configuration'

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.fail_fast = false
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.include FactoryGirl::Syntax::Methods
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!

  config.before do
    # https://github.com/thoughtbot/factory_girl/issues/793
    FactoryGirl.find_definitions
  end

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end



Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |file| require file }
