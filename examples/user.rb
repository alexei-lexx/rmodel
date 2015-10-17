require 'rmodel'

class User
  attr_accessor :id, :name, :email
end

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

session = Moped::Session.new([ "127.0.0.1:27017" ])
session.use 'rmodel_development'
userRepo = UserRepository.new(session)

user = User.new
user.name = 'John Doe'
user.email = 'john@example.com'
p userRepo.insert(user)

p userRepo.find(user.id)

user.name = 'Smith'
p userRepo.update(user)

p userRepo.find(user.id)

p userRepo.remove(user)

p userRepo.find(user.id)
