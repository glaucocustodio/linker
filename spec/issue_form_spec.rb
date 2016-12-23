require 'spec_helper'

describe IssueForm do
  let(:issue_form) { described_class.new(Issue.new) }

  it { expect(described_class._main_model).to eq('Issue') }

  describe "attributes" do
    subject { issue_form.issue }
    it { expect(subject).to be_an(Issue) }
    it { expect(subject.name).to eq(nil) }
    it { expect(subject.owner_id).to eq(nil) }
    it { expect(subject.owner_type).to eq(nil) }
  end

  describe "save" do
    let(:user) { User.create(name: "John") }
    let(:params) do
      {
        name: "Bla",
        owner_id: user.id,
        owner_type: user.class.name
      }
    end
    before do
      issue_form.params = params
      issue_form.save
    end

    it { expect(Issue.count).to eq(1) }

    subject { Issue.last }
    it { expect(subject.name).to eq("Bla") }
    it { expect(subject.owner_id).to eq(user.id) }
    it { expect(subject.owner_type).to eq("User") }
  end
end
