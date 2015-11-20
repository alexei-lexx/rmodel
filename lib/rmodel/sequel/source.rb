module Rmodel
  module Sequel
    class Source
      def initialize(connection, table)
        @connection = connection
        @table = table
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
    end
  end
end
