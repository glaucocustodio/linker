require 'linker'

class CarsForm
  include Linker
  attr_accessor :before_save_checked, :after_save_checked

  main_model :car

  validates :name, presence: true

  validate :car_parts_required

  def car_parts_required
    errors.add(:car_parts_list, "You must choose a car part") if car.car_parts.blank?
  end

  def after_init
    self.name = 'default car name'
  end

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
