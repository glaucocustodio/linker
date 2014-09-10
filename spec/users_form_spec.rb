require 'spec_helper'

describe UsersForm do
  let(:users_form) { UsersForm.new(User.new) }
  let(:users_form_existing_user) { UsersForm.new(User.find(1)) }

  it { expect(UsersForm._main_model).to eq('User') }

  subject(:users_form_to_model) { users_form.to_model }
  it { expect(users_form_to_model.class).to eq(User) }
  it { expect(users_form_to_model.persisted?).to eq(false) }

  it { expect(UsersForm.ancestors).to include(Linker) }
  it { expect(UsersForm.ancestors).to include(ActiveModel::Validations) } if Rails.version.to_i < 4
  it { expect(UsersForm.ancestors).to include(ActiveModel::Model) } if Rails.version.to_i >= 4

  it { expect(users_form).to respond_to(:user) }
  subject(:user) { users_form.user }
  it { expect(user).to be_an(User) }  

  it { expect(users_form).to respond_to(:params=) }
  it { expect(users_form).to respond_to(:save) }

  it { expect(users_form).to respond_to(:dependent_users, :dependent_users_attributes=) }
  it { expect(users_form.dependent_users).to be_an(Array) }

  subject(:dependent_users_sample) { users_form.dependent_users.sample }
  it { expect(dependent_users_sample).to be_an(DependentUser) }

  it { expect(users_form).to respond_to(:my_tasks, :my_tasks_attributes=) }
  it { expect(users_form.my_tasks).to be_an(Array) }
  subject(:tasks_sample) { users_form.my_tasks.sample }
  it { expect(tasks_sample).to be_an(Task) }

  it { expect(users_form).to respond_to(:address, :address_attributes=) }
  subject(:address) { users_form.address }
  it { expect(address).to be_an(Address) }

  it { expect(users_form).to respond_to(:profile_list) }
  subject(:profile_list) { users_form.profile_list }
  it { expect(profile_list).to eq(nil) }

  it { expect(users_form).to respond_to(:my_phone_list) }
  subject(:my_phone_list) { users_form.my_phone_list }
  it { expect(my_phone_list).to eq(nil) }

  it { expect(users_form).to respond_to(:little_pet, :little_pet_attributes=) }
  subject(:pet) { users_form.little_pet }
  it { expect(pet).to be_an(Pet) }

  it { expect(users_form).to respond_to(:company, :company_attributes=) }
  subject(:company) { users_form.company }
  it { expect(company).to be_an(Company) }

  it { expect(users_form).to respond_to(:my_family, :my_family_attributes=) }
  subject(:family) { users_form.my_family }
  it { expect(family).to be_an(Family) }

  context 'new' do
    it { expect(user.persisted?).to eq(false) }  
  
    it { expect(users_form.save).to eq(false) }
    it { expect(users_form).not_to be_valid }
    it do
      users_form.save
      expect(users_form.errors.full_messages).to include("Name can't be blank") 
    end

    it { expect(dependent_users_sample.persisted?).to eq(false) }  

    it { expect(tasks_sample.persisted?).to eq(false) }  

    it { expect(address.persisted?).to eq(false) }  

    it { expect(profile_list).to eq(nil) }

    it { expect(my_phone_list).to eq(nil) }

    it { expect(pet.persisted?).to eq(false) }  

    it { expect(company.persisted?).to eq(false) }  

    it { expect(family.persisted?).to eq(false) }  
  end

  context 'create' do
    before do
      users_form.params = {
        'name'                       => "Foo",
        'company_attributes'         => {'id' => '', 'name' => 'My Company', 'website' => 'mycompany.com'},
        'my_family_attributes'       => {'id' => '', 'last_name' => 'Milan'},
        'address_attributes'         => {'id' => '', 'street' => '', 'district' => ''},
        'profile_list'               => '1',
        'my_phone_list'              => '2',
        'little_pet_attributes'      => {'id' => '', 'name' => 'Stuart'},
        'my_tasks_attributes'        => {'0' => {'id' => '', 'name' => 'T1'}, '1' => {'id' => '', 'name' => 'T2'}},
        'dependent_users_attributes' => {'0' => {'id' => '', 'name' => '', 'date_birth' => ''}, '1' => {'id' => '', 'name' => '', 'date_birth' => ''}}
      }
      users_form.save
    end

    it { expect(users_form).to be_valid }
    it { expect(user.persisted?).to eq(true) }
    it { expect(user.name).to eq('Foo') }

    subject(:user_tasks) { user.my_tasks }
    it { expect(tasks_sample.persisted?).to eq(true) }
    it { expect(users_form.my_tasks.first.id).to eq(user.my_tasks.first.id) }
    it { expect(user_tasks.first.name).to eq('T1') }
    it { expect(user_tasks.last.name).to eq('T2') }

    it { expect(dependent_users_sample.persisted?).to eq(true) }
    it { expect(dependent_users_sample.name).to eq('') }
    
    it { expect(profile_list).to eq(1) }
    it { expect(my_phone_list).to eq(2) }

    it { expect(pet).to be_a(Pet)}
    it { expect(pet.persisted?).to be(true)}
    it { expect(pet.updated_at).to eq(pet.created_at)}
    it { expect(pet.name).to eq('Stuart')}

    subject(:user_company) { user.company }
    it { expect(user_company.persisted?).to eq(true) }
    it { expect(users_form.company.id).to eq(user_company.id) }
    it { expect(user_company.name).to eq('My Company') }
    it { expect(user_company.website).to eq('mycompany.com') }

    subject(:user_family) { user.my_family }
    it { expect(user_family.persisted?).to eq(true) }
    it { expect(user_family.id).to eq(user_family.id) }
    it { expect(user_family.last_name).to eq('Milan') }
  end

  context 'update' do
    before do
      users_form_existing_user.params = {
        'name'                       => "Bar",
        'company_attributes'         => {'id' => '', 'name' => 'My Company', 'website' => 'mycompany.com'},
        'my_family_attributes'       => {'id' => '', 'last_name' => 'Milan'},
        'address_attributes'         => {'id' => '', 'street' => '', 'district' => ''},
        'profile_list'               => '',
        'my_phone_list'              => '',
        'little_pet_attributes'      => {'id' => '1', 'name' => 'Stuart 2'},
        #'tasks_attributes'           => {'0' => {'id' => '', 'name' => 'T1'}, '1' => {'id' => '', 'name' => 'T2'}},
        'dependent_users_attributes' => {'0' => {'id' => '1', 'name' => 'John 2', 'date_birth' => Date.new(1990, 2, 2)}, '1' => {'id' => '', 'name' => '', 'date_birth' => ''}}
      }
      users_form_existing_user.save
    end

    subject(:users_form_existing_user_user) { users_form_existing_user.user }
    subject(:users_form_existing_user_dependent_users) { users_form_existing_user.dependent_users }
    subject(:users_form_existing_user_user_dependent_users) { users_form_existing_user.user.dependent_users }
    subject(:users_form_existing_user_company) { users_form_existing_user.company }
    subject(:users_form_existing_user_address) { users_form_existing_user.address }
    subject(:users_form_existing_user_pet) { users_form_existing_user.little_pet }
    subject(:users_form_existing_user_family) { users_form_existing_user.my_family }
    subject(:users_form_existing_user_user_tasks) { users_form_existing_user.user.my_tasks }
    subject(:users_form_existing_user_tasks_sample) { users_form_existing_user.my_tasks.sample }

    subject(:users_form_existing_user_to_model) { users_form_existing_user.to_model }
    it { expect(users_form_existing_user_to_model.class).to eq(User) }
    it { expect(users_form_existing_user_to_model.persisted?).to eq(true) }

    it { expect(users_form_existing_user_user_tasks.empty?).to be(true) }
    it { expect(users_form_existing_user_tasks_sample.persisted?).to be(false) }
    it { expect(users_form_existing_user_tasks_sample).to be_a(Task) }

    it { expect(users_form_existing_user_dependent_users.sample.persisted?).to eq(true) }
    it { expect(users_form_existing_user_dependent_users.first.id).to eq(1) }
    it { expect(users_form_existing_user_dependent_users.first.updated_at).not_to eq(users_form_existing_user_dependent_users.first.created_at) }
    it { expect(users_form_existing_user_dependent_users.last.updated_at).to eq(users_form_existing_user_dependent_users.last.created_at) }
    it { expect(users_form_existing_user_dependent_users.first.name).to eq('John 2') }

    it { expect(users_form_existing_user_user_dependent_users.sample.persisted?).to eq(true)}
    it { expect(users_form_existing_user_user_dependent_users.first.id).to eq(1)}
    it { expect(users_form_existing_user_user_dependent_users.first.name).to eq('John 2')}

    it { expect(users_form_existing_user_user.persisted?).to eq(true)}
    it { expect(users_form_existing_user_user.name).to eq('Bar')}
    
    it { expect(users_form_existing_user_company.persisted?).to be(true) }
    it { expect(users_form_existing_user_company.name).to eq('My Company') }
    it { expect(users_form_existing_user_company.website).to eq('mycompany.com') }

    it { expect(users_form_existing_user_family.persisted?).to be(true) }
    it { expect(users_form_existing_user_family.last_name).to eq('Milan') }
    
    it { expect(users_form_existing_user.profile_list).to be(nil) }
    it { expect(users_form_existing_user.my_phone_list).to be(nil) }

    it { expect(users_form_existing_user_pet).to be_a(Pet) }
    it { expect(users_form_existing_user_pet.persisted?).to be(true) }
    it { expect(users_form_existing_user_pet.updated_at).not_to eq(users_form_existing_user_pet.created_at)}
    it { expect(users_form_existing_user_pet.name).to eq('Stuart 2') }

    it { expect(users_form_existing_user_address.persisted?).to be(true) }
    it { expect(users_form_existing_user_address.street).to eq('') }
    it { expect(users_form_existing_user_address.district).to eq('') }
  end
end