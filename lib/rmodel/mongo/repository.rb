require 'mongo'
require 'active_support/inflector'
require 'rmodel/mongo/repository_ext/queryable'

module Rmodel::Mongo
  class Repository
    include RepositoryExt::Queryable

    attr_accessor :session, :collection, :factory
    private 'session=', 'collection=', 'factory='

    def initialize(session = nil, collection = nil, factory = nil)
      self.session = session || self.class.setting_session ||
                      Rmodel.sessions[:default] or
                      raise ArgumentError.new('Session can not be guessed')

      self.collection = collection || self.class.setting_collection ||
                      self.class.collection_by_convention or
                      raise ArgumentError.new('Collection can not be guessed')

      self.factory = factory || self.class.setting_factory or
                      raise ArgumentError.new('Factory can not be guessed')
    end

    def find(id)
      result = self.session[collection].find(_id: id).first
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
      self.session[collection].insert_one(@factory.toHash(object, true))
    end

    def update(object)
      self.session[collection].find(_id: object.id).update_one(@factory.toHash(object, false))
    end

    def remove(object)
      self.session[collection].find(_id: object.id).delete_one
    end

    class << self
      attr_accessor :setting_session, :setting_collection, :setting_factory

      def session(name)
        self.setting_session = Rmodel.sessions[name]
      end

      alias_method :collection, 'setting_collection='

      def collection_by_convention
        if name =~ /(.*)Repository$/
          ActiveSupport::Inflector.tableize($1).to_sym
        end
      end

      def simple_factory(klass, *attributes)
        self.setting_factory = SimpleFactory.new(klass, *attributes)
      end
    end
  end
end
