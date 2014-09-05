class User < ActiveRecord::Base
  belongs_to :company
  belongs_to :family

  has_one :address, dependent: :destroy

  has_many :dependent_users, dependent: :destroy
  has_many :tasks, dependent: :destroy

  #has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  #validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
end

class Address < ActiveRecord::Base
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

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.references :company, index: true
      t.references :family, index: true

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
  end
end
ActiveRecord::Migration.verbose = false
CreateAllTables.up

# seed
bar = User.create(name: 'Bar')
bar.tasks << Task.create(name: 'Task 1')
bar.dependent_users << DependentUser.create(name: 'John', date_birth: Date.new(1990, 2, 1))