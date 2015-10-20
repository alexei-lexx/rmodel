require 'rmodel'

User = Struct.new(:id, :name, :email)

Rmodel.sessions[:default] = Mongo::Client.new([ '127.0.0.1:27017' ], database: 'rmodel_development')

class UserFactory < Rmodel::Mongo::SimpleFactory
  def initialize
    super(User, :name, :email)
  end
end

class UserRepository < Rmodel::Mongo::Repository
  def initialize
    super(nil, :users, UserFactory.new)
  end
end

userRepo = UserRepository.new

john = User.new(nil, 'John', 'john@example.com')
bill = User.new(nil, 'Bill', 'bill@example.com')
bob = User.new(nil, 'Bob', 'bob@example.com')

userRepo.insert(john)
userRepo.insert(bill)
userRepo.insert(bob)
