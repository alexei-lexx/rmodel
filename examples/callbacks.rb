require 'rmodel'

Rmodel.setup do
  client :default, hosts: ['localhost'], database: 'test'
end

class Thing
  attr_accessor :id, :name

  def initialize(name = nil)
    self.name = name
  end
end

class ThingMapper < Rmodel::Mongo::Mapper
  attributes :name
end

class ThingRepository < Rmodel::Mongo::Repository
  # the module below isn't included by default
  include Rmodel::Base::RepositoryExt::Callbackable

  before_insert do |thing|
    thing.name ||= 'noname'
  end

  after_insert :print_something

  def print_something(_thing)
    p "I've been just inserted"
  end

  # before_update, after_update, before_remove, after_remove
end

repo = ThingRepository.new
repo.query.remove # clear the collection

repo.insert(Thing.new)
repo.insert(Thing.new('chair'))
p repo.query.to_a
