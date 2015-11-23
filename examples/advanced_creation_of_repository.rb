require 'rmodel'

class Thing
  attr_accessor :id, :name
end

class ThingMapper < Rmodel::Mongo::Mapper
  model Thing
  attributes :name
end

class ThingRepository < Rmodel::Base::Repository
end

connection = Mongo::Client.new(['localhost:27017'], database: 'test')
collection = :things
source = Rmodel::Mongo::Source.new(connection, collection)
mapper = ThingMapper.new

repo = ThingRepository.new(source, mapper)
p repo.find(1)
