require 'rmodel'

Rmodel.setup do
  client :default, { hosts: [ 'localhost'], database: 'test' }
end

Owner = Struct.new(:id, :first_name, :last_name)

Room = Struct.new(:id, :name, :square)

Flat = Struct.new(:id, :address, :rooms, :owner)

class OwnerFactory < Rmodel::Mongo::SimpleFactory
  def initialize
    super Owner, :first_name, :last_name
  end
end

class RoomFactory < Rmodel::Mongo::SimpleFactory
  def initialize
    super Room, :name, :square
  end
end

class FlatFactory < Rmodel::Mongo::SimpleFactory
  def initialize
    super Flat, :address
    embeds_many :rooms, RoomFactory.new
    embeds_one :owner, OwnerFactory.new
  end
end

class FlatRepository < Rmodel::Mongo::Repository
  def initialize
    super nil, nil, FlatFactory.new
  end
end
repo = FlatRepository.new
repo.query.remove

flat = Flat.new
flat.address = 'Googleplex, Mountain View, California, U.S'
flat.rooms = []
flat.rooms << Room.new(nil, 'dining room', 150)
flat.rooms << Room.new(nil, 'sleeping room #1', 50)
flat.rooms << Room.new(nil, 'sleeping room #2', 20)
flat.owner = Owner.new(nil, 'John', 'Doe')

repo.insert(flat)

p repo.find(flat.id)
