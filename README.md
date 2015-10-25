[![Build Status](https://travis-ci.org/alexei-lexx/rmodel.svg)](https://travis-ci.org/alexei-lexx/rmodel)

# Rmodel

Rmodel is an ORM library, which tends to follow the SOLID principles.

The main thoughts behind it are:

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

class UserRepository < Rmodel::Mongo::Repository
end

userRepository = UserRepository.new
```
The code above raises the exception *Client driver is not setup (ArgumentError)*. UserRepository derives from Rmodel::Mongo::Repository, which uses the ruby mongo driver to access the database. We must provide the appropriate connection options. To do this we use the following code:

```ruby
require 'rmodel'

Rmodel.setup do
  client :default, { hosts: [ 'localhost' ], database: 'test' }
end
```

The `:default` client is used by every repository that doesn't specify it's client explicitly.

Run the code again and get another error *Factory can not be guessed (ArgumentError)*. The factory is used to convert the array of database tuples (hashes) to the array of User objects.

```ruby
class UserRepository < Rmodel::Mongo::Repository
  simple_factory User, :name, :email
end
```

The `simple_factory` class macro says that every database tuple will be straightforwardly converted to an instance of User with  attributes :id, :name and :email. There is no need to specify :id, because it's required.

### CRUD

Let's create and insert several users.

```ruby
john = User.new('John', 'john@example.com')
bill = User.new('Bill', 'bill@example.com')
bob = User.new('Bob', 'bob@example.com')

userRepository.insert(john)
userRepository.insert(bill)
userRepository.insert(bob)
```

Now you can check you `test` database. There are 3 new users there. Print the `john`. As you can see it's got the `@id`.

```ruby
p john
#<User:0x00... @name="John", @email="john@example.com", @id=BSON::ObjectId('562a...')>
```

Let's update John and remove Bob.

```ruby
john.name = 'John Smith'
userRepository.update(john)

userRepository.remove(bob)

p userRepository.find(john.id) # #<User:0x000000037237d0 @name="John Smith" ... >
p userRepository.find(bob.id) # nil
p userRepository.find!(bob.id) # raises Rmodel::NotFound
```

### Scopes

Scopes are defined inside the repository.

```ruby
class UserRepository < Rmodel::Mongo::Repository
  simple_factory User, :name, :email

  scope :have_email do
    where(email: { '$exists' => true })
  end

  scope :start_with do |letter|
    where(name: { '$regex' => "^#{letter}", '$options' => 'i' })
  end
end

userRepository.query.start_with('b').to_a
```

Of course you can chain scopes.

```ruby
userRepository.query.start_with('b').have_email
```

The result of the scope is Enumerable, so you can apply the #each method and others (map, select etc).

Inside the scopes you can use any methods supported by the driver (database client). In our case we use Origin (https://github.com/mongoid/origin) as a query builder for mongo.

Also it's possible to use scopes to run the multi-row operations.

```ruby
userRepository.query.have_email.remove
p userRepository.query.count # 0
```

### Timestamps

Here is an example how to track the time, when the entity was created and updated.

```ruby
class Thing
  attr_accessor :id, :name, :created_at, :updated_at
end

class ThingRepository < Rmodel::Mongo::Repository
  simple_factory Thing, :name, :created_at, :updated_at
end
repo = ThingRepository.new

thing = Thing.new
thing.name = 'chair'
repo.insert(thing)
p thing.created_at

sleep 2

thing.name = 'table'
repo.update(thing)
p thing.updated_at
```

To enable time tracking  just add attributes `created_at` and `updated_at` or one of them to your entity.

## Contributing

1. Fork it ( https://github.com/alexei-lexx/rmodel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
