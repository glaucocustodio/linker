class User < ActiveRecord::Base
  belongs_to :company
  belongs_to :my_family, class_name: 'Family'

  has_one :address, dependent: :destroy
  has_one :profile
  has_one :my_phone, class_name: 'Phone'
  has_one :little_pet, class_name: 'Pet'

  has_many :dependent_users, dependent: :destroy
  has_many :my_tasks, dependent: :destroy, class_name: 'Task'

  #has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  #validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
end

class Address < ActiveRecord::Base
end

class Pet < ActiveRecord::Base
end

class Company < ActiveRecord::Base
  has_many :users
end

class DependentUser < ActiveRecord::Base
  belongs_to :user
end

class Family < ActiveRecord::Base
end

class Task < ActiveRecord::Base
  attr_accessor :error_message
end

class Profile < ActiveRecord::Base
end

class Phone < ActiveRecord::Base
end

class Car < ActiveRecord::Base
end

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.references :company, index: true
      t.references :my_family, index: true

      t.timestamps
    end

    create_table :companies do |t|
      t.string :name
      t.string :website

      t.timestamps
    end

    create_table :dependent_users do |t|
      t.string :name
      t.date :date_birth
      t.references :user, index: true

      t.timestamps
    end

    create_table :tasks do |t|
      t.string :name
      t.references :user, index: true

      t.timestamps
    end

    create_table :families do |t|
      t.string :last_name

      t.timestamps
    end

    create_table :addresses do |t|
      t.string :street
      t.string :district

      t.references :user, index: true
      
      t.timestamps
    end

    create_table :pets do |t|
      t.string :name

      t.references :user, index: true
      
      t.timestamps
    end

    create_table :profiles do |t|
      t.string :profile_type
      t.references :user, index: true

      t.timestamps
    end

    create_table :phones do |t|
      t.string :phone_number
      t.references :user, index: true

      t.timestamps
    end

    create_table :cars do |t|
      t.string :name

      t.timestamps
    end

  end
end
ActiveRecord::Migration.verbose = false
CreateAllTables.up

Profile.create(profile_type: 'A')
Profile.create(profile_type: 'B')
Profile.create(profile_type: 'C')

Phone.create(phone_number: 'ZA')
Phone.create(phone_number: 'ZB')
Phone.create(phone_number: 'ZC')

# seed
bar = User.create(name: 'Bar')
bar.my_tasks << Task.create(name: 'Task 1')
bar.little_pet = Pet.create(name: 'Stuart')
bar.profile = Profile.first
bar.dependent_users << DependentUser.create(name: 'John', date_birth: Date.new(1990, 2, 1))