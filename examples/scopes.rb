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

repo = UserRepository.new(source, mapper)
repo.query.remove

repo.insert(User.new(nil, 'John', 'john@example.com'))
repo.insert(User.new(nil, 'Bill', 'bill@example.com'))
repo.insert(User.new(nil, 'Bob'))

p repo.query.start_with('b').to_a
p repo.query.start_with('b').have_email.to_a
p repo.query.count
