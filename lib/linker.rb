require "linker/version"
require 'active_support/all'
require 'linker/forms/attributes'
require 'linker/forms/params'

module Linker 
  extend ActiveSupport::Concern
  include Linker::Attributes
  include Linker::Params

  def initialize main_model_instance = self.class._main_model.constantize.send(:new)
    # Creating instance variable for main model
    instance_variable_set("@#{main_model_instance.class.name.underscore}", main_model_instance)

    prepare_attrs
    after_init
  end

  def after_init
  end

  included do
    # allow use form instance variable in form_for. Ie: form_for(@user_form)
    def to_model
      instance_variable_get("@#{self.class._main_model.underscore}")
    end
  end
end