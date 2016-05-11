require 'rmodel'

DB = Mongo::Client.new(['localhost'], database: 'test')

class UserRepository < Rmodel::Repository
  scope :start_with do |s|
    where(name: { '$regex' => "^#{s}", '$options' => 'i' })
  end

  def initialize
    source = Rmodel::Mongo::Source.new(DB, :users)
    mapper = Rmodel::Mongo::Mapper.new(User).define_attributes(:name, :email)

    super(source, mapper)
  end

  def fetch_johns
    fetch.start_with('john')
  end
end

User = Struct.new(:id, :name, :email) do
  include UserRepository.injector
end

User.delete_all

john = User.new(nil, 'John', 'john@example.com')
User.insert(john)

john.name = 'John Smith'
User.update(john)

User.insert(User.new)

p User.fetch.start_with('J').count
p User.fetch_johns.count
