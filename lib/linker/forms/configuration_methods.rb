module Linker
  module ConfigurationMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def main_model(main_model)
        @main_model = main_model.to_s.camelize
      end

      def _main_model
        @main_model ||= self.name.split("Form").first
      end
    end

    included do
      if Rails.version.to_i >= 4
        include ActiveModel::Model
      else
        include ActiveModel::Validations
      end
    end
  end
end
