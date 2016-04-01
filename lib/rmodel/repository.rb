require 'rmodel/repository_ext/sugarable'
require 'rmodel/repository_ext/timestampable'
require 'rmodel/repository_ext/queryable'

module Rmodel
  class Repository
    include RepositoryExt::Sugarable
    include RepositoryExt::Queryable

    def self.inherited(subclass)
      subclass.send :prepend, RepositoryExt::Timestampable
    end

    def initialize(source, mapper)
      @source = source or fail ArgumentError, 'Source is not setup'
      @mapper = mapper or fail ArgumentError, 'Mapper can not be guessed'
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
