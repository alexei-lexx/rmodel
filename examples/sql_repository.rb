require 'rmodel'

Rmodel.setup do
  # see more examples of connection options
  # http://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html#label-Passing+a+block+to+either+method
  client :default, { adapter: 'sqlite', database: 'rmodel_test.sqlite3' }
end

client = Rmodel.setup.establish_sequel_client(:default)
client.drop_table? :things
client.create_table :things do
  primary_key :id
  String :name
  Float :price
end

class Thing
  attr_accessor :id, :name, :price

  def initialize(name = nil, price = nil)
    self.name = name
    self.price = price
  end
end

class ThingRepository < Rmodel::Sequel::Repository
  simple_mapper Thing, :name, :price

  scope :worth_more_than do |amount|
    # use Sequel dataset filtering http://sequel.jeremyevans.net/rdoc/files/doc/dataset_filtering_rdoc.html
    where { price >= amount }
  end
end

repo = ThingRepository.new
repo.insert Thing.new('iPod', 200)
repo.insert Thing.new('iPhone', 300)
repo.insert Thing.new('iPad', 500)

p repo.query.count # 3
p repo.query.worth_more_than(400).count # 1
p repo.query.worth_more_than(400).to_sql
