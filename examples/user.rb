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
    where(email: { '$regex' => /@example\.com$/i })
  end

  scope :start_with do |letter|
    where(name: { '$regex' => "^#{letter}", '$options' => 'i' })
  end
end

userRepo = UserRepository.new

john = User.new(nil, 'John', 'john@example.com')
bill = User.new(nil, 'Bill', 'bill@example.com')
bob = User.new(nil, 'Bob', 'bob@test.com')

userRepo.insert(john)
userRepo.insert(bill)
userRepo.insert(bob)

p '--------------------------------'
p userRepo.query.example_com.count
p '--------------------------------'
p userRepo.query.example_com.start_with('b').count
p '--------------------------------'
p userRepo.query.start_with('b').count

p '================================'
userRepo.query.start_with('b').remove
p userRepo.query.count

begin
  p userRepo.find!(john.id)
  p userRepo.find!(bill.id)
rescue Rmodel::NotFound => err
  p err
end
