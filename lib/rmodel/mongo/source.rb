require 'mongo'

module Rmodel
  module Mongo
    class Source
      def initialize(connection, collection)
        @connection = connection
        raise ArgumentError, 'Connection is not setup' unless @connection

        @collection = collection
        raise ArgumentError, 'Collection can not be guessed' unless @collection
      end

      def find(id)
        @connection[@collection].find('_id' => id).first
      end

      def insert(doc)
        doc = doc.merge('_id' => BSON::ObjectId.new) if doc['_id'].nil?
        @connection[@collection].insert_one(doc)
        doc['_id']
      end

      def update(id, doc)
        @connection[@collection].find(_id: id).update_one(doc)
      end

      def delete(id)
        @connection[@collection].find(_id: id).delete_one
      end

      def build_query
        Query.new
      end

      def exec_query(query)
        @connection[@collection].find(query.selector, query.options)
      end

      def delete_by_query(query)
        exec_query(query).delete_many
      end
    end
  end
end
