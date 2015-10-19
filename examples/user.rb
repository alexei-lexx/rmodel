require 'rmodel'

User = Struct.new(:id, :name, :email)

class UserFactory < Rmodel::Mongodb::SimpleFactory
  def initialize
    super(User, :name, :email)
  end
end

class UserRepository < Rmodel::Mongodb::Repository
  def initialize(session)
    super(session, :users, UserFactory.new)
  end
end

session = Mongo::Client.new([ '127.0.0.1:27017' ], database: 'rmodel_development')
userRepo = UserRepository.new(session)

john = User.new(nil, 'John', 'john@example.com')
bill = User.new(nil, 'Bill', 'bill@example.com')
bob = User.new(nil, 'Bob', 'bob@example.com')

userRepo.insert(john)
userRepo.insert(bill)
userRepo.insert(bob)
