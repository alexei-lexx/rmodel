require 'rmodel'

Rmodel.setup do
  connection :default do
    Mongo::Client.new(['localhost'], database: 'test')
  end
end

class Thing
  attr_accessor :id, :name, :created_at, :updated_at
end

class ThingMapper < Rmodel::Mongo::Mapper
  attributes :name, :created_at, :updated_at
end

class ThingRepository < Rmodel::Repository
  source do
    Rmodel::Mongo::Source.new(Rmodel.setup.connection(:default), :things)
  end
end
repo = ThingRepository.new

thing = Thing.new
thing.name = 'chair'
repo.insert(thing)
p "#{thing.created_at} / #{thing.updated_at}"

sleep 2

thing.name = 'table'
repo.update(thing)
p "#{thing.created_at} / #{thing.updated_at}"
