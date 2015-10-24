require 'rmodel'

Rmodel.setup do
  client :default, { hosts: [ 'localhost' ], database: 'test' }
end

class User
  attr_accessor :id, :name, :email

  def initialize(name = nil, email = nil)
    self.name = name
    self.email = email
  end
end

class UserRepository < Rmodel::Mongo::Repository
  simple_factory User, :name, :email

  scope :have_email do
    where(email: { '$exists' => true })
  end

  scope :start_with do |letter|
    where(name: { '$regex' => "^#{letter}", '$options' => 'i' })
  end
end

userRepository = UserRepository.new
userRepository.query.remove

john = User.new('John', 'john@example.com')
bill = User.new('Bill', 'bill@example.com')
bob = User.new('Bob', 'bob@example.com')

userRepository.insert(john)
userRepository.insert(bill)
userRepository.insert(bob)

john.name = 'John Smith'
userRepository.update(john)

userRepository.remove(bob)

p userRepository.find(john.id)
p userRepository.find(bob.id)

userRepository.query.have_email.remove
p userRepository.query.count
