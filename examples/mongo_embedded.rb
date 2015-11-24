require 'rmodel'

Rmodel.setup do
  connection :default do
    Mongo::Client.new(['localhost'], database: 'test')
  end
end

Owner = Struct.new(:first_name, :last_name)
Bed = Struct.new(:type)
Room = Struct.new(:name, :square, :bed)
Flat = Struct.new(:id, :address, :rooms, :owner)

class OwnerMapper < Rmodel::Mongo::Mapper
  model Owner
  attributes :first_name, :last_name
end

class BedMapper < Rmodel::Mongo::Mapper
  model Bed
  attributes :type
end

class RoomMapper < Rmodel::Mongo::Mapper
  model Room
  attributes :name, :square
  attribute :bed, BedMapper.new
end

class FlatMapper < Rmodel::Mongo::Mapper
  model Flat
  attributes :address
  attribute :rooms, Rmodel::ArrayMapper.new(RoomMapper.new)
  attribute :owner, OwnerMapper.new
end

class FlatRepository < Rmodel::Repository
  source do
    Rmodel::Mongo::Source.new(Rmodel.setup.connection(:default), :flats)
  end
  mapper FlatMapper
end

repo = FlatRepository.new
repo.query.remove

flat = Flat.new
flat.address = 'Googleplex, Mountain View, California, U.S'
flat.rooms = [
  Room.new('dining room', 150),
  Room.new('sleeping room #1', 50, Bed.new('single')),
  Room.new('sleeping room #2', 20, Bed.new('king-size'))
]
flat.owner = Owner.new('John', 'Doe')

repo.insert(flat)
p repo.find(flat.id)
