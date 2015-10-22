require 'rmodel'

User = Struct.new(:id, :name, :email)

Rmodel.sessions[:default] = Mongo::Client.new([ '127.0.0.1:27017' ], database: 'rmodel_development')

class UserRepository < Rmodel::Mongo::Repository
  simple_factory User, :name, :email

  def initialize
    super(nil, nil, nil)
  end
end

userRepo = UserRepository.new

john = User.new(nil, 'John', 'john@example.com')
bill = User.new(nil, 'Bill', 'bill@example.com')
bob = User.new(nil, 'Bob', 'bob@example.com')

userRepo.insert(john)
userRepo.insert(bill)
userRepo.insert(bob)
