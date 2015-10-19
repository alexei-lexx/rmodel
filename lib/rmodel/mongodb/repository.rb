require 'mongo'

module Rmodel::Mongodb
  class Repository
    def initialize(session, collection, factory)
      @collection = session[collection]
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
  end
end
