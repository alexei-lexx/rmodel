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

User = Struct.new(:id, :name, :email)

DB = Mongo::Client.new(['localhost'], database: 'test')
source = Rmodel::Mongo::Source.new(DB, :users)

mapper = Rmodel::Mongo::Mapper.new(User).define_attributes(:name, :email)

user_repository = Rmodel::Repository.new(source, mapper)
```

Here 3 main components of Rmodel are described:
1. `source` points to the `users` collection withing MongoDB.
2. `mapper` is an example of a mapper class instance. It's methods
`#initialize` and `define_attributes` are used to declare the mapping rules
(User -> Hash and Hash -> User). It's a rather easy mapper. Every database
tuple is straightforwardly converted to an instance of User with  attributes
:id, :name and :email. There is no need to specify :id.
3. Finally, `user_repository` takes `source` and `mapper` and makes all magic
about fetching and saving users from/to the database.

### CRUD

Let's create and insert several users.

```ruby
john = User.new(nil, 'John', 'john@example.com')
bill = User.new(nil, 'Bill', 'bill@example.com')
bob = User.new(nil, 'Bob', 'bob@example.com')

user_repository.insert(john)
user_repository.insert(bill)
user_repository.insert(bob)
```

Now you can check you `test` database. There must be 3 new users there. Print
the `john`. As you can see it's got the `@id`.

```ruby
p john
#<struct User id=BSON::ObjectId('...'), name="John", email="john@example.com">
```

Let's update John and destroy Bob.

```ruby
john.name = 'John Smith'
user_repository.update(john)

user_repository.destroy(bob)

p user_repository.find(john.id) # <struct User id=BSON::ObjectId('...'), ...>
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
  scope :have_email do
    where(email: { '$exists' => true })
  end

  scope :start_with do |letter|
    where(name: { '$regex' => "^#{letter}", '$options' => 'i' })
  end
end

repo = UserRepository.new(source, mapper)

p repo.query.start_with('b').to_a
```

Of course you can chain scopes.

```ruby
p repo.query.start_with('b').have_email.to_a
```

The result of the scope is Enumerable, so you can apply the #each method and
others (map, select etc).

Inside the scopes you can use any methods supported by the driver (database
connection). In our case we use Origin (https://github.com/mongoid/origin) as
a query builder for mongo.

Also it's possible to use scopes to run the multi-row operations.

```ruby
repo.query.have_email.remove # simply run the operation against the database
repo.query.have_email.destroy # extract users and run repo.destroy for the each one
p repo.query.count # 0
```

### Timestamps

Here is an example how to track the time, when the entity was created and updated.

```ruby
require 'rmodel'

DB = Mongo::Client.new(['localhost'], database: 'test')
source = Rmodel::Mongo::Source.new(DB, :things)

class Thing
  attr_accessor :id, :name, :created_at, :updated_at
end

mapper = Rmodel::Mongo::Mapper.new(Thing)
                              .define_attribute(:name)
                              .define_attributes(:created_at, :updated_at)

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
repo.remove_all
repo.destroy_all
```

The `save` method can be used instead of `insert` and `update`.
If the object has no not-nil id then it gets inserted. Otherwise it gets updated.

The `find!` method works like the simple `find`
, but instead of nil it raises the Rmodel::NotFound error.

The `remove_all` and `destroy_all` methods clean up the table/collection
within the database. The last one calls `destroy` for each object.

### SQL repository

SQL amenities is based on the Sequel gem (http://sequel.jeremyevans.net/).
So the big range of SQL databases is supported.

> Sequel currently has adapters for ADO, Amalgalite, CUBRID, DataObjects, IBM_DB, JDBC, MySQL, Mysql2, ODBC, Oracle, PostgreSQL, SQLAnywhere, SQLite3, Swift, and TinyTDS.

Below you can the the example how to setup Rmodel for any supported SQL database.

```ruby
require 'rmodel'

DB = Sequel.connect(adapter: 'sqlite', database: 'rmodel_test.sqlite3')
source = Rmodel::Sequel::Source.new(DB, :things)

DB.drop_table? :things
DB.create_table :things do
  primary_key :id
  String :name
  Float :price
end

Thing = Struct.new :id, :name, :price
mapper = Rmodel::Sequel::Mapper.new(Thing).define_attributes(:name, :price)

class ThingRepository < Rmodel::Repository
  scope :worth_more_than do |amount|
    # use Sequel dataset filtering http://sequel.jeremyevans.net/rdoc/files/doc/dataset_filtering_rdoc.html
    where { price >= amount }
  end
end

repo = ThingRepository.new(source, mapper)
repo.insert Thing.new(nil, 'iPod', 200)
repo.insert Thing.new(nil, 'iPhone', 300)
repo.insert Thing.new(nil, 'iPad', 500)

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
source = Rmodel::Mongo::Source.new(DB, :flats)

Owner = Struct.new(:first_name, :last_name)
Bed = Struct.new(:type)
Room = Struct.new(:name, :square, :bed)
Flat = Struct.new(:id, :address, :rooms, :owner)

owner_mapper = Rmodel::Mongo::Mapper.new(Owner)
                                    .define_attributes(:first_name, :last_name)

bed_mapper = Rmodel::Mongo::Mapper.new(Bed).define_attribute(:type)

room_mapper = Rmodel::Mongo::Mapper.new(Room)
                                   .define_attributes(:name, :square)
                                   .define_attribute(:bed, bed_mapper)

rooms_mapper = Rmodel::ArrayMapper.new(room_mapper)
flat_mapper =  Rmodel::Mongo::Mapper.new(Flat)
                                    .define_attribute(:address)
                                    .define_attribute(:rooms, rooms_mapper)
                                    .define_attribute(:owner, owner_mapper)

repo = Rmodel::Repository.new(source, flat_mapper)
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
