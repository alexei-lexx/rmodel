require 'mongo'
require 'active_support/inflector'
require 'rmodel/mongo/repository_ext/queryable'
require 'rmodel/mongo/repository_ext/timestampable'
require 'rmodel/mongo/repository_ext/sugarable'

module Rmodel::Mongo
  class Repository
    include RepositoryExt::Queryable
    prepend RepositoryExt::Timestampable
    include RepositoryExt::Sugarable

    def initialize(client = nil, collection = nil, factory = nil)
      @client = client || Rmodel.setup.establish_mongo_client(self.class.client_name || :default) or
                raise ArgumentError.new('Client driver is not setup')

      @collection = collection || self.class.setting_collection ||
                    self.class.collection_by_convention or
                    raise ArgumentError.new('Collection can not be guessed')

      @factory = factory || self.class.setting_factory or
                 raise ArgumentError.new('Factory can not be guessed')
    end

    def find(id)
      result = @client[@collection].find(_id: id).first
      result && @factory.fromHash(result)
    end

    def insert(object)
      object.id ||= BSON::ObjectId.new
      @client[@collection].insert_one(@factory.toHash(object, true))
    end

    def update(object)
      @client[@collection].find(_id: object.id).update_one(@factory.toHash(object, false))
    end

    def remove(object)
      @client[@collection].find(_id: object.id).delete_one
    end

    class << self
      attr_reader :client_name, :setting_collection, :setting_factory

      def client(name)
        @client_name = name
      end

      def collection(name)
        @setting_collection = name
      end

      def collection_by_convention
        if name =~ /(.*)Repository$/
          ActiveSupport::Inflector.tableize($1).to_sym
        end
      end

      def simple_factory(klass, *attributes)
        @setting_factory = SimpleFactory.new(klass, *attributes)
      end
    end
  end
end
