require 'rmodel'

DB = Mongo::Client.new(['localhost'], database: 'test')
source = Rmodel::Mongo::Source.new(DB, :things)

Thing = Struct.new(:id, :name, :created_at, :updated_at)
mapper = Rmodel::Mongo::Mapper.new(Thing)
                              .define_attribute(:name)
                              .define_timestamps

repo = Rmodel::Repository.new(source, mapper)

thing = Thing.new
thing.name = 'chair'
repo.insert(thing)
p "#{thing.created_at} / #{thing.updated_at}"

sleep 2

thing.name = 'table'
repo.update(thing)
p "#{thing.created_at} / #{thing.updated_at}"
