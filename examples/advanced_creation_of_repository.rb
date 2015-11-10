require 'rmodel'

class Thing
  attr_accessor :id, :name
end

class ThingRepository < Rmodel::Mongo::Repository
end

client = Mongo::Client.new([ 'localhost:27017' ], database: 'test')
collection = :things
mapper = Rmodel::Mongo::SimpleMapper.new(Thing, :name)

repo = ThingRepository.new(client, collection, mapper)
p repo.find(1)
