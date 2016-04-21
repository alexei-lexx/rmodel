module Rmodel
  module RepositoryExt
    module Queryable
      def query
        query_klass.new(self, @source.build_query)
      end

      def find_by_query(query)
        @source.exec_query(query).map do |hash|
          @mapper.deserialize(hash)
        end
      end

      def delete_by_query(query)
        @source.delete_by_query(query)
      end

      def destroy_by_query(query)
        @source.exec_query(query).map do |hash|
          object = @mapper.deserialize(hash)
          destroy(object)
        end
      end

      def define_scope(name, &block)
        query_klass.define_scope(name, &block)
        self
      end

      private

      def query_klass
        @query_klass ||= Class.new(Rmodel::QueryBuilder)
      end
    end
  end
end
