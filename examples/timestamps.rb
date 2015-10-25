require 'rmodel'

Rmodel.setup do
  client :default, { hosts: [ 'localhost' ], database: 'test' }
end

class Thing
  attr_accessor :id, :name, :created_at, :updated_at
end

class ThingRepository < Rmodel::Mongo::Repository
  simple_factory Thing, :name, :created_at, :updated_at
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
