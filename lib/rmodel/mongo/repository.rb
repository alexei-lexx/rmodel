require 'mongo'
require 'rmodel/mongo/repository_ext/queryable'

module Rmodel::Mongo
  class Repository < Rmodel::Base::Repository
    include RepositoryExt::Queryable

    def initialize(client = nil, collection = nil, mapper = nil)
      @client = client || Rmodel.setup.establish_mongo_client(self.class.client_name || :default) or
                raise ArgumentError.new('Client driver is not setup')

      @collection = collection || self.class.setting_collection ||
                    self.class.collection_by_convention or
                    raise ArgumentError.new('Collection can not be guessed')

      @mapper = mapper || self.class.declared_mapper ||
                self.class.mapper_by_convention or
                raise ArgumentError.new('Mapper can not be guessed')
    end

    def find(id)
      result = @client[@collection].find(_id: id).first
      result && @mapper.deserialize(result)
    end

    def insert_one(object)
      object.id ||= BSON::ObjectId.new
      @client[@collection].insert_one(@mapper.serialize(object, true))
    end

    def update(object)
      @client[@collection].find(_id: object.id).update_one(@mapper.serialize(object, false))
    end

    def destroy(object)
      @client[@collection].find(_id: object.id).delete_one
    end

    class << self
      attr_reader :client_name, :setting_collection, :declared_mapper

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

      def mapper_by_convention
        if name =~ /(.*)Repository$/
          ActiveSupport::Inflector.constantize($1 + 'Mapper').new
        end
      rescue NameError
        nil
      end

      def mapper(mapper_klass)
        @declared_mapper = mapper_klass.new
      end
    end
  end
end
