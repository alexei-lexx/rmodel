require 'rmodel'

DB = Mongo::Client.new(['localhost'], database: 'test')

class User
  attr_accessor :id, :name, :email

  def initialize(name = nil, email = nil)
    self.name = name
    self.email = email
  end
end

class UserMapper < Rmodel::Mongo::Mapper
  model User
  attributes :name, :email
end

class UserRepository < Rmodel::Repository
  scope :have_email do
    where(email: { '$exists' => true })
  end

  scope :start_with do |letter|
    where(name: { '$regex' => "^#{letter}", '$options' => 'i' })
  end
end

source = Rmodel::Mongo::Source.new(DB, :users)
user_repository = UserRepository.new(source, UserMapper.new)
user_repository.query.remove

john = User.new('John', 'john@example.com')
bill = User.new('Bill', 'bill@example.com')
bob = User.new('Bob', 'bob@example.com')

user_repository.insert(john)
user_repository.insert(bill)
user_repository.insert(bob)

john.name = 'John Smith'
user_repository.update(john)

user_repository.destroy(bob)

p user_repository.find(john.id)
p user_repository.find(bob.id)

user_repository.query.have_email.remove
p user_repository.query.count
