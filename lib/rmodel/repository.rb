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
      @mapper.deserialize(@source.find(id))
    end

    def insert_one(object)
      id = @source.insert(@mapper.serialize(object, true))
      object.id ||= id
    end

    def update(object)
      @source.update(object.id, @mapper.serialize(object, false))
    end

    def destroy(object)
      @source.delete(object.id)
    end
  end
end
