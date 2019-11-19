require "rack/test"
require "rspec"

ENV["RACK_ENV"] = "test"

require File.expand_path "../../app.rb", __FILE__
RSPEC_ROOT = File.dirname __FILE__
RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

# For RSpec 2.x and 3.x
RSpec.configure { |c| c.include RSpecMixin }
