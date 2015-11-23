require 'rmodel/base/repository_ext/sugarable'
require 'rmodel/base/repository_ext/timestampable'
require 'rmodel/base/repository_ext/queryable'

module Rmodel
  module Base
    class Repository
      include RepositoryExt::Sugarable
      include RepositoryExt::Queryable
      def self.inherited(subclass)
        subclass.send :prepend, RepositoryExt::Timestampable
      end

      def initialize(source, mapper)
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
        attr_reader :declared_source
        attr_reader :declared_connection_name, :declared_mapper

        def source(&block)
          @declared_source = block
        end

        def connection(name)
          @declared_connection_name = name
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
end
