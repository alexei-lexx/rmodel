[![Build Status](https://travis-ci.org/alexei-lexx/rmodel.svg)](https://travis-ci.org/alexei-lexx/rmodel)

# Rmodel

* [Installation](#installation)
* [Usage](#usage)
  * [CRUD](#crud)
  * [Scopes](#scopes)
  * [Timestamps](#timestamps)
  * [Sugar methods](#sugar-methods)
  * [Advanced creation of repository](#advanced-creation-of-repository)
  * [SQL repository](#sql-repository)
  * [Embedded documents in MongoDB](#embedded-documents-in-mongodb)

Rmodel is an ORM library, which tends to follow the SOLID principles.

**Currently works with MongoDB and SQL databases supported by Sequel.**

The main thoughts of it are:

* let you models be simple and independent of the persistent layer,
* be able to switch the persistent layer at any moment,
* be able to use different databases for different entities,
* keep the simplicity of the Active Record pattern by default,
* be able to implement any type of persistence: SQL, NoSQL, files, HTTP etc.

It consists of 3 major components:

1. **Entities**; ex.: User, Order etc.
2. **Repositories**, which are used to fetch, save and delete entities; ex.: UserRepository, OrderRepository
3. **Mappers**, which are used to serialize/deserialize entities to/from database tuples.

Basic implemented features:

1. CRUD operations: `find`, `insert`, `update`, `destroy`;
2. Scopes: `userRepository.query.recent.sorted`;
3. Query-based operations: `userRepository.query.recent.remove`.

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

As you see it's a PORO (Plain Old Ruby Objects), a class which inherits from nothing.
It must have either the zero-argument `#initialize` method or no `#initialize` at all.

Of course we need a repository to save users.

```ruby
require 'rmodel' # dont forget to require the gem

class User
  attr_accessor :id, :name, :email

  def initialize(name = nil, email = nil)
    @name = name
    @email = email
  end
end

DB = Mongo::Client.new(['localhost'], database: 'test')
source = Rmodel::Mongo::Source.new(DB, :users)

class UserMapper < Rmodel::Mongo::Mapper
  model User
  attributes :name, :email
end

mapper = UserMapper.new

user_repository = Rmodel::Repository.new(source, mapper)
```

Here 3 main components of Rmodel are described:
1. `source` points to the `users` collection withing MongoDB.
2. The `UserMapper` class is an example of mappers.
It's macroses such as `model` and `attributes` are used to declare the mapping rules (User -> Hash and Hash -> User). It's a rather easy mapper. Every database tuple is straightforwardly converted to an instance of User with  attributes :id, :name and :email. There is no need to specify :id.
3. Finally, `user_repository` takes `source` and `mapper` and makes all magic about fetching and saving users from/to the database.

### CRUD

Let's create and insert several users.

```ruby
john = User.new('John', 'john@example.com')
bill = User.new('Bill', 'bill@example.com')
bob = User.new('Bob', 'bob@example.com')

user_repository.insert(john)
user_repository.insert(bill)
user_repository.insert(bob)
```

Now you can check you `test` database. There must be 3 new users there. Print the `john`. As you can see it's got the `@id`.

```ruby
p john
#<User:0x00... @name="John", @email="john@example.com", @id=BSON::ObjectId('562a...')>
```

Let's update John and destroy Bob.

```ruby
john.name = 'John Smith'
user_repository.update(john)

user_repository.destroy(bob)

p user_repository.find(john.id) # #<User:0x000000037237d0 @name="John Smith" ... >
p user_repository.find(bob.id) # nil
```

The `insert` method is polysemantic. All options below are valid.

```ruby
repo.insert(object)
repo.insert([ object1, object2, object3 ])
repo.insert(object1, object2, object3)
```

### Scopes

Scopes are defined inside the repository.

```ruby
class UserRepository < Rmodel::Repository
  def initialize
    source = Rmodel::Mongo::Source.new(DB, :users)
    mapper = UserMapper.new
    super(source, mapper)
  end

  scope :have_email do
    where(email: { '$exists' => true })
  end

  scope :start_with do |letter|
    where(name: { '$regex' => "^#{letter}", '$options' => 'i' })
  end
end

repo = UserRepository.new

p repo.query.start_with('b').to_a
```

Of course you can chain scopes.

```ruby
p repo.query.start_with('b').have_email.to_a
```

The result of the scope is Enumerable, so you can apply the #each method and others (map, select etc).

Inside the scopes you can use any methods supported by the driver (database connection). In our case we use Origin (https://github.com/mongoid/origin) as a query builder for mongo.

Also it's possible to use scopes to run the multi-row operations.

```ruby
repo.query.have_email.remove # simply run the operation against the database
repo.query.have_email.destroy # extract users and run repo.destroy for the each one
p repo.query.count # 0
```

It's possible to use so-called **inline** scopes. They aren't defined within
the repository, but are written directly in the query.

```ruby
repo.query.scope { where(age: { '$gte' => 20 }) }.count
```

### Timestamps

Here is an example how to track the time, when the entity was created and updated.

```ruby
require 'rmodel'

DB = Mongo::Client.new(['localhost'], database: 'test')

class Thing
  attr_accessor :id, :name, :created_at, :updated_at
end

class ThingMapper < Rmodel::Mongo::Mapper
  model Thing
  attributes :name, :created_at, :updated_at
end

source = Rmodel::Mongo::Source.new(DB, :things)
mapper = ThingMapper.new
repo = Rmodel::Repository.new(source, mapper)

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

### Sugar methods

```ruby
repo.save(thing)
repo.find!(1)
```

The `save` method can be used instead of `insert` and `update`.
If the object has no not-nil id then it gets inserted. Otherwise it gets updated.

The `find!` method works like the simple `find`
, but instead of nil it raises the Rmodel::NotFound error.

### SQL repository

SQL amenities is based on the Sequel gem (http://sequel.jeremyevans.net/).
So the big range of SQL databases is supported.

> Sequel currently has adapters for ADO, Amalgalite, CUBRID, DataObjects, IBM_DB, JDBC, MySQL, Mysql2, ODBC, Oracle, PostgreSQL, SQLAnywhere, SQLite3, Swift, and TinyTDS.

Below you can the the example how to setup Rmodel for any supported SQL database.

```ruby
require 'rmodel'

DB = Sequel.connect(adapter: 'sqlite', database: 'rmodel_test.sqlite3')

DB.drop_table? :things
DB.create_table :things do
  primary_key :id
  String :name
  Float :price
end

class Thing
  attr_accessor :id, :name, :price

  def initialize(name = nil, price = nil)
    self.name = name
    self.price = price
  end
end

class ThingMapper < Rmodel::Sequel::Mapper
  model Thing
  attributes :name, :price
end

class ThingRepository < Rmodel::Repository
  def initialize
    source = Rmodel::Sequel::Source.new(DB, :things)
    mapper = ThingMapper.new
    super(source, mapper)
  end

  scope :worth_more_than do |amount|
    # use Sequel dataset filtering http://sequel.jeremyevans.net/rdoc/files/doc/dataset_filtering_rdoc.html
    where { price >= amount }
  end
end

repo = ThingRepository.new
repo.insert Thing.new('iPod', 200)
repo.insert Thing.new('iPhone', 300)
repo.insert Thing.new('iPad', 500)

p repo.query.count # 3
p repo.query.worth_more_than(400).count # 1
```

### Embedded documents in MongoDB

Let's assume that we have the `flats` collection and every documents reveals the following structure.

```js
> db.flats.findOne()
{
	"_id" : ObjectId("5632910ee5fcc32d40000000"),
	"address" : "Googleplex, Mountain View, California, U.S",
	"rooms" : [
		{
			"name" : "dining room",
			"square" : 150,
			"_id" : ObjectId("5632910ee5fcc32d40000001")
		},
		{
			"name" : "sleeping room #1",
			"square" : 50,
			"_id" : ObjectId("5632910ee5fcc32d40000002"),
			"bed" : {
				"type" : "single",
				"_id" : ObjectId("5632910ee5fcc32d40000003")
			}
		},
		{
			"name" : "sleeping room #2",
			"square" : 20,
			"_id" : ObjectId("5632910ee5fcc32d40000004"),
			"bed" : {
				"type" : "king-size",
				"_id" : ObjectId("5632910ee5fcc32d40000005")
			}
		}
	],
	"owner" : {
		"first_name" : "John",
		"last_name" : "Doe",
		"_id" : ObjectId("5632910ee5fcc32d40000006")
	}
}
```

We need a rather complicated mapper to build such object. Here is the example how we can map nested embedded documents with Rmodel::Mongo::Mapper.

The idea is easy:
* define primitive mappers,
* use them in declaration of composite mappers.

```ruby
require 'rmodel'

DB = Mongo::Client.new(['localhost'], database: 'test')

Owner = Struct.new(:first_name, :last_name)
Bed = Struct.new(:type)
Room = Struct.new(:name, :square, :bed)
Flat = Struct.new(:id, :address, :rooms, :owner)

class OwnerMapper < Rmodel::Mongo::Mapper
  model Owner
  attributes :first_name, :last_name
end

class BedMapper < Rmodel::Mongo::Mapper
  model Bed
  attributes :type
end

class RoomMapper < Rmodel::Mongo::Mapper
  model Room
  attributes :name, :square
  attribute :bed, BedMapper.new
end

class FlatMapper < Rmodel::Mongo::Mapper
  model Flat
  attributes :address
  attribute :rooms, Rmodel::ArrayMapper.new(RoomMapper.new)
  attribute :owner, OwnerMapper.new
end

source = Rmodel::Mongo::Source.new(DB, :flats)
mapper = FlatMapper.new

repo = Rmodel::Repository.new(source, mapper)
repo.query.remove

flat = Flat.new
flat.address = 'Googleplex, Mountain View, California, U.S'
flat.rooms = [
  Room.new('dining room', 150),
  Room.new('sleeping room #1', 50, Bed.new('single')),
  Room.new('sleeping room #2', 20, Bed.new('king-size'))
]
flat.owner = Owner.new('John', 'Doe')

repo.insert(flat)
p repo.find(flat.id)
```

## Contributing

1. Fork it ( https://github.com/alexei-lexx/rmodel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
