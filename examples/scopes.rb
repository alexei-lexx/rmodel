require 'rmodel' # dont forget to require the gem

User = Struct.new(:id, :name, :email)

Mongo::Logger.logger.level = ::Logger::WARN
DB = Mongo::Client.new(['localhost'], database: 'test')
source = Rmodel::Mongo::Source.new(DB, :users)

mapper = Rmodel::Mongo::Mapper.new(User).define_attributes(:name, :email)

class UserRepository < Rmodel::Repository
  scope :have_email do
    where(email: { '$ne' => nil })
  end

  scope :start_with do |letter|
    where(name: { '$regex' => "^#{letter}", '$options' => 'i' })
  end
end

repo = UserRepository.new(source, mapper)
repo.query.remove

repo.insert(User.new(nil, 'John', 'john@example.com'),
            User.new(nil, 'Bill', 'bill@example.com'),
            User.new(nil, 'Bob'))

p repo.query.start_with('b').to_a
p repo.query.start_with('b').have_email.to_a

repo.query.have_email.remove # simply run the operation against the database
repo.query.have_email.destroy # run repo.destroy for each user
p repo.query.count # 1
