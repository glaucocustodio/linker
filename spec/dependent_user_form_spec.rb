require 'spec_helper'

describe DependentUserForm do
  let(:du_form) { DependentUserForm.new(DependentUser.new) }

  it { expect(DependentUserForm._main_model).to eq('DependentUser') }
  it { expect(du_form.to_model).to be_a(DependentUser) }
  it { expect(du_form.to_model.persisted?).to eq(false) }
end