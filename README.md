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
  
  has_many :dependent_users, dependent: :destroy
  has_many :tasks, dependent: :destroy
end
```

Create a form class, include Linker and set main model:
```ruby
class UsersForm
  include Linker
  
  main_model User # or :user or 'User'
end
```

Now you can create a new form for existing user `UsersForm.new(User.find params[:id])` or to a new one `UsersForm.new(User.new)`:
```ruby
class UsersController < ApplicationController
  def new
    @user_form = UsersForm.new(User.new)
  end

  def create
    @user_form.params = users_form_params

    if @user_form.save
      redirect_to users_path, notice: 'User created successfully'
    else
      render :new
    end
  end
end
```

By default, `save` method will perform validations, you can disable them by passing `validate: false` as parameter.

Finally, you can use `fields_for` in order to display associated fields.

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
<% end %>
```

## How it works

Linker will map all `has_one`, `has_many` and `belongs_to` associations from main model and let it ready to use.

Internally, it will include `ActiveModel::Model` if on Rails 4 or `ActiveModel::Validations` if on Rails < 4.

It will also create `params=` and `save` methods responsible to set new objects and save them. You can override these methods to get a custom behavior without worrying with delegations.

You can check out a demo project using Linker gem [here](https://github.com/glaucocustodio/linker_demo). [Click here](http://linker-demo.herokuapp.com/) to see it live.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This projected is licensed under the terms of the MIT license.