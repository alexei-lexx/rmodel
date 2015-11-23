require 'sequel'

module Rmodel
  module Sequel
    class Source
      def initialize(connection, table)
        @connection = connection
        fail ArgumentError, 'Connection is not setup' unless @connection

        @table = table
        fail ArgumentError, 'Table can not be guessed' unless @table
      end

      def find(id)
        @connection[@table].where(id: id).first
      end

      def insert(tuple)
        @connection[@table].insert(tuple)
      end

      def update(id, tuple)
        @connection[@table].where(id: id).update(tuple)
      end

      def delete(id)
        @connection[@table].where(id: id).delete
      end

      def build_query
        @connection[@table]
      end

      def exec_query(query)
        query
      end

      def delete_by_query(query)
        exec_query(query).delete
      end
    end
  end
end
