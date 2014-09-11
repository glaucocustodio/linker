require 'linker'

class UsersForm
  include Linker

  main_model :user

  validates  :name, presence: true
end