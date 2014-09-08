module Rails
  module Generators
    class FormGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      desc <<DESC
Description:
    Stubs out a form class in app/forms directory.

Examples:
    `rails g form user`

    This creates:
        app/forms/user_form.rb
DESC

      def create_form_file
        template 'form.rb', File.join('app/forms', "#{singular_name}_form.rb")
      end

      hook_for :test_framework
    end
  end
end