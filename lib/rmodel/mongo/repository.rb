require 'mongo'

module Rmodel::Mongo
  class Repository
    attr_accessor :session
    private 'session='

    def initialize(session, collection, factory)
      self.session = session || self.class.setting_session ||
                      Rmodel.sessions[:default] or
                      raise ArgumentError.new('Session can not be nil')

      @collection = self.session[collection]
      @factory = factory
    end

    def find(id)
      result = @collection.find(_id: id).first
      if result
        @factory.fromHash(result)
      else
        nil
      end
    end

    def insert(object)
      if object.id.nil?
        object.id = BSON::ObjectId.new
      end
      @collection.insert_one(@factory.toHash(object, true))
    end

    def update(object)
      @collection.find(_id: object.id).update_one(@factory.toHash(object, false))
    end

    def remove(object)
      @collection.find(_id: object.id).delete_one
    end

    class << self
      attr_accessor :setting_session

      def session(name)
        self.setting_session = Rmodel.sessions[name]
      end
    end
  end
end
