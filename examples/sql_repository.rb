require 'rmodel'

DB = Sequel.connect(adapter: 'sqlite', database: 'rmodel_test.sqlite3')

DB.drop_table? :things
DB.create_table :things do
  primary_key :id
  String :name
  Float :price
end

Thing = Struct.new(:id, :name, :price)

class ThingMapper < Rmodel::Sequel::Mapper
  model Thing
  attributes :name, :price
end

source = Rmodel::Sequel::Source.new(DB, :things)

class ThingRepository < Rmodel::Repository
  scope :worth_more_than do |amount|
    # use Sequel dataset filtering http://sequel.jeremyevans.net/rdoc/files/doc/dataset_filtering_rdoc.html
    where { price >= amount }
  end
end

repo = ThingRepository.new(source, ThingMapper.new)
repo.insert Thing.new(nil, 'iPod', 200)
repo.insert Thing.new(nil, 'iPhone', 300)
repo.insert Thing.new(nil, 'iPad', 500)

p repo.query.count # 3
p repo.query.worth_more_than(400).count # 1
