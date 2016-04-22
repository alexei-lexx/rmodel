require 'rmodel/repository_ext/sugarable'
require 'rmodel/repository_ext/timestampable'
require 'rmodel/repository_ext/scopable'

module Rmodel
  class Repository
    include RepositoryExt::Sugarable
    include RepositoryExt::Scopable
    prepend RepositoryExt::Timestampable

    def initialize(source, mapper)
      @source = source or raise ArgumentError, 'Source is not set up'
      @mapper = mapper or raise ArgumentError, 'Mapper is not set up'
    end

    def find(id)
      record = @source.find(id)
      @mapper.deserialize(record)
    end

    def insert_one(object)
      record = @mapper.serialize(object, true)
      id = @source.insert(record)
      object.id ||= id
    end

    def update(object)
      record = @mapper.serialize(object, false)
      @source.update(object.id, record)
    end

    def destroy(object)
      @source.delete(object.id)
    end
  end
end
