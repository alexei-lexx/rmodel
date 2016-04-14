require 'rmodel'

DB = Mongo::Client.new(['localhost'], database: 'test')
source = Rmodel::Mongo::Source.new(DB, :users)

User = Struct.new(:id, :name, :email)
mapper = Rmodel::Mongo::Mapper.new(User).define_attributes(:name, :email)

class UserRepository < Rmodel::Repository
  scope :have_email do
    where(email: { '$exists' => true })
  end

  scope :start_with do |letter|
    where(name: { '$regex' => "^#{letter}", '$options' => 'i' })
  end
end

user_repository = UserRepository.new(source, mapper)
user_repository.query.remove

john = User.new(nil, 'John', 'john@example.com')
bill = User.new(nil, 'Bill', 'bill@example.com')
bob = User.new(nil, 'Bob', 'bob@example.com')

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
