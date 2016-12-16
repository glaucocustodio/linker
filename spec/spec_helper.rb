require 'awesome_print'
require 'pry'
require 'rails'

if defined? Rails
  require 'fake_app/rails_app'
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
