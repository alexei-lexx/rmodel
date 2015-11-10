require 'rmodel'

Rmodel.setup do
  client :default, { hosts: [ 'localhost'], database: 'test' }
end

Owner = Struct.new(:id, :first_name, :last_name)
Room = Struct.new(:id, :name, :square, :bed)
Flat = Struct.new(:id, :address, :rooms, :owner)
Bed = Struct.new(:id, :type)

class FlatRepository < Rmodel::Mongo::Repository
  simple_mapper Flat, :address do
    embeds_many :rooms, simple_mapper(Room, :name, :square) do
      embeds_one :bed, simple_mapper(Bed, :type)
    end
    embeds_one :owner, simple_mapper(Owner, :first_name, :last_name)
  end
end
repo = FlatRepository.new
repo.query.remove

flat = Flat.new
flat.address = 'Googleplex, Mountain View, California, U.S'
flat.rooms = [
  Room.new(nil, 'dining room', 150),
  Room.new(nil, 'sleeping room #1', 50, Bed.new(nil, 'single')),
  Room.new(nil, 'sleeping room #2', 20, Bed.new(nil, 'king-size'))
]
flat.owner = Owner.new(nil, 'John', 'Doe')

repo.insert(flat)
p repo.find(flat.id)
