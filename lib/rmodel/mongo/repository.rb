require 'mongo'
require 'active_support/inflector'
require 'rmodel/mongo/repository_ext/queryable'

module Rmodel::Mongo
  class Repository
    include RepositoryExt::Queryable

    attr_reader :collection, :factory

    def initialize
      @collection = self.class.setting_collection ||
                    self.class.collection_by_convention or
                    raise ArgumentError.new('Collection can not be guessed')

      @factory = self.class.setting_factory or
                 raise ArgumentError.new('Factory can not be guessed')
    end

    def client
      client_name = self.class.client_name || :default
      config = Rmodel.setup.clients[client_name]
      raise ArgumentError.new('Client driver is not setup') if config.nil?

      hosts = config[:hosts]
      options = config.dup
      options.delete :hosts

      @client ||= Mongo::Client.new(hosts, options)
    end

    def find(id)
      result = self.client[collection].find(_id: id).first
      if result
        @factory.fromHash(result)
      else
        nil
      end
    end

    def find!(id)
      find(id) or raise Rmodel::NotFound.new(self, { id: id })
    end

    def insert(object)
      if object.id.nil?
        object.id = BSON::ObjectId.new
      end
      self.client[collection].insert_one(@factory.toHash(object, true))
    end

    def update(object)
      self.client[collection].find(_id: object.id).update_one(@factory.toHash(object, false))
    end

    def remove(object)
      self.client[collection].find(_id: object.id).delete_one
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
