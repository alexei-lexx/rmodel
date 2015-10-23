# Rmodel

Rmodel is an ORM library, which tends to follow the SOLID principles.

The main thouhgts behind it are:

* let you models be simple and independent of the persistent layer,
* be able to switch the persistent layer at any moment,
* keep the simplicity of the Active Record pattern by default,
* be able to implement any type of persistence: SQL, NoSQL, files, HTTP etc.

It consists of 3 major components:

1. **Entities**; ex.: User, Order etc.
2. **Repositories**, which are used to fetch, save and delete entities; ex.: UserRepository, OrderRepository
3. **Factories**, which play the role of mappers.

Basic implemented features:

1. CRUD operations: `find`, `insert`, `update`, `remove`;
2. Scopes: `userRepository.query.recent.sorted`
3. Based on query operations: `userRepository.query.recent.remove`

## Installation

Add this line to your application's Gemfile:

    gem 'rmodel'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rmodel

## Usage

Let's define an entity

```ruby
class User
  attr_accessor :id, :name, :email
end
```

As you see it's a plain ruby class with attributes. It must have either the zero-argument `#initialize` method or no `#initialize` at all.

Of course we need a repository to save users.

```ruby
require 'rmodel' # dont forget to require the gem

class User
  attr_accessor :id, :name, :email
end

class UserRepository
  simple_factory User, :name, :email
end

userRepository = UserRepository.new
```


Let's create and save a new user.

```ruby
require 'rmodel' # dont forget to require the gem

class User
  attr_accessor :id, :name, :email
end

class UserRepository
  simple_factory User, :name, :email
end

userRepository = UserRepository.new

john = User.new
john.name = 'John'
userRepository.insert(john)
```


## Contributing

1. Fork it ( https://github.com/alexei-lexx/rmodel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
