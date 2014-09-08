module Rspec
  class FormGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def create_spec_file
      template 'form_spec.rb', File.join('spec/forms', "#{singular_name}_form_spec.rb")
    end
  end
end