# Linker [![Build Status](https://travis-ci.org/glaucocustodio/linker.svg?branch=master)](https://travis-ci.org/glaucocustodio/linker)

A wrapper to form objects in ActiveRecord. Forget `accepts_nested_attributes_for`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'linker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install linker

## Supported versions
- Ruby 2.0+
- Rails 3.1+ (including 4.x)

## Usage

Given the below model:
```ruby
class User < ActiveRecord::Base
  belongs_to :company
  belongs_to :family

  has_one :address, dependent: :destroy
  has_one :profile
  
  has_many :dependent_users, dependent: :destroy
  has_many :tasks, dependent: :destroy
end
```

Create a form class through `rails g form whatever` or manually (it should include Linker and have main model set like below).
```ruby
class UserForm
  include Linker
  
  main_model User # or :user or 'User'

  # Use relationship's name followed by "__" plus attribute's name 
  # to validate has_one and belongs_to associations
  validates :name, :address__street, :company__name, presence: true
end
```

Now you can create a new form for existing user `UserForm.new(User.find params[:id])` or to a new one `UserForm.new`:
```ruby
class UsersController < ApplicationController
  def new
    @user_form = UserForm.new # same as UserForm.new(User.new)
  end

  def create
    @user_form = UserForm.new(User.new)
    @user_form.params = users_form_params

    if @user_form.save
      redirect_to users_path, notice: 'User created successfully'
    else
      render :new
    end
  end

  def edit
    @user_form = UserForm.new(User.find(params[:id])) # you need to load the record being edited
  end
end
```

By default, `save` method will perform validations, you can disable them by passing `validate: false` as parameter.

Finally, you can use `fields_for` in order to create/edit associated fields and the suffix `_list` (like `profile_list` below) to choose an existing associated record.

```erb
<%= form_for @user_form do |f| %>
  <%= f.text_field :name %>
  
  <%= f.fields_for :tasks do |ta| %>
    <%= ta.hidden_field :id %>
    <%= ta.text_field :name %>

  <%= f.fields_for :company do |co| %>
    <%= co.hidden_field :id %>
    <%= co.text_field :name %>
    <%= co.text_field :website %>

  <%= f.select :profile_list, Profile.all.map{|c| [c.profile_type, c.id]}, include_blank: true %>

<% end %>
```

## How it works

Linker will map all `has_one`, `has_many` and `belongs_to` associations from main model and let it ready to use.

Internally, it will include `ActiveModel::Model` if on Rails 4 or `ActiveModel::Validations` if on Rails < 4.

It will also create `params=` and `save` methods responsible to set new objects and save them. You can override these methods to get a custom behavior without worrying with delegations.

You can check out a demo project using Linker gem [here](https://github.com/glaucocustodio/linker_demo). [Click here](http://linker-demo.herokuapp.com/) to see it live.

## Callbacks

There are some callbacks you can override to keep your controllers DRY:

* `after_init`: runs after `initialize` method of form class. Can be used to set default field values or to prepare data to form.
* `before_set_params(params)`: runs before `params=` method. Can be used to change params inside the form class, like string formatting.
* `before_save`: runs before save method.
* `after_save`: runs after save method. You can enqueue some background job here for instance.

Example:

```ruby
class CarsForm
  include Linker
  attr_accessor :before_save_checked

  main_model :car

  validates :name, presence: true

  def before_set_params params
    params['name'] = "#{params['name']} 2000"
  end

  def before_save
    @before_save_checked = true
  end

  def after_save
    HardWorker.perform_async('bob', 5)
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This projected is licensed under the terms of the MIT license.