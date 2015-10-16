require 'moped'
require 'bson'

module Rmodel
  module Mongodb
    class Repository
      def initialize(session, collection, factory)
        @collection = session[collection]
        @factory = factory
      end

      def find(id)
        result = @collection.find(_id: id).first
        if result
          @factory.buildInstance(result)
        else
          nil
        end
      end

      def insert(object)
        if object.id.nil?
          object.id = BSON::ObjectId.new
        end
        result = @collection.insert(@factory.buildHash(object, true))
        result['err'].nil?
      end

      def update(object)
        result = @collection.find(_id: object.id).update(@factory.buildHash(object, false))
        result['err'].nil?
      end

      def remove(object)
        result = @collection.find(_id: object.id).remove
        result['err'].nil?
      end
    end
  end
end
