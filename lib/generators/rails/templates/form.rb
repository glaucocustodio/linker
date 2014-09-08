class <%= class_name %>Form
  include Linker
  
  main_model <%= class_name.singularize.camelize %>
end