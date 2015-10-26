require 'rmodel'

class Thing
  attr_accessor :id, :name
end

class ThingRepository < Rmodel::Mongo::Repository
end

client = Mongo::Client.new([ 'localhost:27017' ], database: 'test')
collection = :things
factory = Rmodel::Mongo::SimpleFactory.new(Thing, :name)

repo = ThingRepository.new(client, collection, factory)
p repo.find(1)
