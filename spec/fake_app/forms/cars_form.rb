require 'linker'

class CarsForm
  include Linker
  attr_accessor :before_save_checked, :after_save_checked

  main_model :car

  validates :name, presence: true

  def before_set_params params
    params['name'] = "#{params['name']} 2000"
  end

  def before_save
    @before_save_checked = true
  end

  def after_save
    @after_save_checked = true
  end
end