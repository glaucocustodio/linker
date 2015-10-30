require 'spec_helper'

describe CarsForm do
  let(:cars_form) { CarsForm.new(Car.new) }

  context 'before_set_params' do
    before do
      cars_form.params = {
        'name' => "Uno"
      }
      cars_form.save
    end

    it { expect(cars_form.car.name).to eq('Uno 2000') }
    it { expect(cars_form.before_save_checked).to eq(true) }
    it { expect(cars_form.after_save_checked).to eq(true) }
  end
end