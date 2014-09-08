module TestUnit
  class FormGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def create_test_file
      template 'form_test.rb', File.join('test/forms', "#{singular_name}_form_test.rb")
    end
  end
end