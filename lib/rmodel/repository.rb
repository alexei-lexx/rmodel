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

    def initialize(source = nil, mapper = nil)
      initialize_source(source)
      initialize_mapper(mapper)
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

    private

    def initialize_source(source)
      @source = source || self.class.declared_source.try(:call)
      fail ArgumentError, 'Source can not be guessed' unless @source
    end

    def initialize_mapper(mapper)
      @mapper = mapper || self.class.declared_mapper ||
                self.class.mapper_by_convention
      fail ArgumentError, 'Mapper can not be guessed' unless @mapper
    end

    class << self
      attr_reader :declared_source, :declared_mapper

      def source(&block)
        @declared_source = block
      end

      def mapper(mapper_klass)
        @declared_mapper = mapper_klass.new
      end

      def mapper_by_convention
        if name =~ /(.*)Repository$/
          mapper_name = Regexp.last_match(1) + 'Mapper'
          ActiveSupport::Inflector.constantize(mapper_name).new
        end
      rescue NameError
        nil
      end
    end
  end
end
