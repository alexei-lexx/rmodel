require 'rmodel/base/repository_ext/callbackable'
require 'rmodel/base/repository_ext/sugarable'
require 'rmodel/base/repository_ext/timestampable'
require 'rmodel/base/repository_ext/queryable'

module Rmodel
  module Base
    class Repository
      include RepositoryExt::Sugarable
      include RepositoryExt::Queryable
      def self.inherited(subclass)
        subclass.send :prepend, RepositoryExt::Callbackable
        subclass.send :prepend, RepositoryExt::Timestampable
      end

      def initialize(type, client, mapper)
        initialize_client(type, client)
        initialize_mapper(mapper)
      end

      def insert(*args)
        if args.length == 1
          if args.first.is_a?(Array)
            insert_array(args.first)
          else
            insert_one(args.first)
          end
        else
          insert_array(args)
        end
      end

      private

      def initialize_client(type, client)
        if client
          @client = client
        else
          client_name = self.class.declared_client_name || :default
          method = "establish_#{type}_client"
          @client = Rmodel.setup.public_send(method, client_name)
        end
        fail ArgumentError, 'Client driver is not setup' unless @client
      end

      def initialize_mapper(mapper)
        @mapper = mapper || self.class.declared_mapper ||
                  self.class.mapper_by_convention
        fail ArgumentError, 'Mapper can not be guessed' unless @mapper
      end

      def insert_array(array)
        array.each { |object| insert_one(object) }
      end

      class << self
        attr_reader :declared_client_name, :declared_mapper

        def client(name)
          @declared_client_name = name
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
