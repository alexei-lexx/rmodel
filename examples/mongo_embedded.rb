require 'rmodel'

DB = Mongo::Client.new(['localhost'], database: 'test')
source = Rmodel::Mongo::Source.new(DB, :flats)

Owner = Struct.new(:first_name, :last_name)
Bed = Struct.new(:type)
Room = Struct.new(:name, :square, :bed)
Flat = Struct.new(:id, :address, :rooms, :owner)

owner_mapper = Rmodel::Mongo::Mapper.new(Owner)
                                    .define_attributes(:first_name, :last_name)

bed_mapper = Rmodel::Mongo::Mapper.new(Bed).define_attribute(:type)

room_mapper = Rmodel::Mongo::Mapper.new(Room)
                                   .define_attributes(:name, :square)
                                   .define_attribute(:bed, bed_mapper)

rooms_mapper = Rmodel::ArrayMapper.new(room_mapper)
flat_mapper =  Rmodel::Mongo::Mapper.new(Flat)
                                    .define_attribute(:address)
                                    .define_attribute(:rooms, rooms_mapper)
                                    .define_attribute(:owner, owner_mapper)

repo = Rmodel::Repository.new(source, flat_mapper)
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
