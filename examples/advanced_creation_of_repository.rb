require 'rmodel'

class Thing
  attr_accessor :id, :name
end

class ThingMapper < Rmodel::Mongo::Mapper
  model Thing
  attributes :name
end

class ThingRepository < Rmodel::Mongo::Repository
end

connection = Mongo::Client.new(['localhost:27017'], database: 'test')
collection = :things
mapper = ThingMapper.new

repo = ThingRepository.new(connection, collection, mapper)
p repo.find(1)
