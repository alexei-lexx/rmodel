require 'rmodel'

Mongo::Logger.logger.level = Logger::WARN

class User
  attr_accessor :id, :name, :email

  def initialize(id = nil, name = nil, email = nil)
    self.id = id
    self.name = name
    self.email = email
  end
end

Rmodel.sessions[:default] = Mongo::Client.new([ '127.0.0.1:27017' ], database: 'rmodel_development')
Rmodel.sessions[:default][:users].drop

class UserRepository < Rmodel::Mongo::Repository
  simple_factory User, :name, :email

  scope :example_com do
    where(email: { '$regex' => /@example\.com$/ })
  end

  scope :bill do
    where(name: 'Bill')
  end

  scope :bob do
    where(name: 'Bob')
  end
end

userRepo = UserRepository.new

john = User.new(nil, 'John', 'john@example.com')
bill = User.new(nil, 'Bill', 'bill@example.com')
bob = User.new(nil, 'Bob', 'bob@test.com')

userRepo.insert(john)
userRepo.insert(bill)
userRepo.insert(bob)

p userRepo.query.example_com.to_a
p '--------------------------------'
p userRepo.query.example_com.bill.to_a
p '--------------------------------'
p userRepo.query.bob.to_a
