require 'spec_helper'

describe CarsForm do
  let(:cars_form) { described_class.new(Car.new) }
  let!(:car_part1) { CarPart.create(name: "Part 1") }
  let!(:car_part2) { CarPart.create(name: "Part 2") }

  it { expect(cars_form.car_parts_list).to eq(nil) }

  context 'after_init callback' do
    it { expect(cars_form.name).to eq('default car name') }
  end

  context 'callbacks and habtm _list' do
    before do
      cars_form.params = {
        'name' => "Uno",
        'car_parts_list' => [1, 2, ""]
      }
      cars_form.save
    end

    it { expect(cars_form.car.name).to eq('Uno 2000') }
    it { expect(cars_form.car.car_parts.ids).to eq([1,2]) }
    it { expect(cars_form.before_save_checked).to eq(true) }
    it { expect(cars_form.after_save_checked).to eq(true) }
  end

  context 'validates empty habtm _list' do
    before do
      cars_form.params = {
        'name' => "Uno",
        'car_parts_list' => [""]
      }
      cars_form.save
    end

    it { expect(cars_form.car.name).to eq('Uno 2000') }
    it { expect(cars_form.car.car_parts.ids).to eq([]) }
    it { expect(cars_form.errors.messages).to include(:car_parts_list) }
  end
end
