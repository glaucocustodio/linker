#require 'action_controller/railtie'
#require 'action_view/railtie'
require 'active_record/railtie'
require 'active_model/railtie'

# config
app                                          = Class.new(Rails::Application)
app.config.secret_token                      = '3b7cd7445w4d5w4d5w4w5566c4'
app.config.session_store :cookie_store, :key => '_myapp_session'
app.config.active_support.deprecation        = :log
app.config.eager_load                        = false
# Rais.root
app.config.root = File.dirname(__FILE__)
Rails.backtrace_cleaner.remove_silencers!
app.initialize!

require_relative 'active_record/models'
require_relative 'forms/dependent_user_form'
require_relative 'forms/users_form'
require_relative 'forms/cars_form'
require_relative 'forms/issue_form'
# controllers
# class ApplicationController < ActionController::Base; end

# class UsersController < ApplicationController
#   def new
#     @users_form = UserForm.new(User.new)
#   end
# end
