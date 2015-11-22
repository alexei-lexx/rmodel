require 'origin'
require 'mongo'

module Rmodel
  module Mongo
    class Source
      class Query
        include Origin::Queryable
      end

      def initialize(connection, collection)
        if connection.is_a? Symbol
          @connection = Rmodel.setup.establish_mongo_connection(connection)
        else
          @connection = connection
        end
        fail ArgumentError, 'Connection is not setup' unless @connection

        @collection = collection
        fail ArgumentError, 'Collection can not be guessed' unless @collection
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