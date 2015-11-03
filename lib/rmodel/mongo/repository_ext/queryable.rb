require 'origin'

module Rmodel::Mongo
  module RepositoryExt
    module Queryable
      def self.included(base)
        base.extend ClassMethods
      end

      class Query
        include Origin::Queryable
      end

      def query
        (self.class.query_klass ||= Class.new(Rmodel::Base::QueryBuilder)).new(self, Query.new)
      end

      def find_by_query(query)
        execute_query(query).map do |hash|
          @factory.to_object(hash)
        end
      end

      def remove_by_query(query)
        execute_query(query).delete_many
      end

      def destroy_by_query(query)
        execute_query(query).map do |hash|
          object = @factory.to_object(hash)
          destroy(object)
        end
      end

      module ClassMethods
        attr_accessor :query_klass

        def scope(name, &block)
          self.query_klass ||= Class.new(Rmodel::Base::QueryBuilder)
          self.query_klass.define_scope(name, &block)
        end
      end

      private

      def execute_query(query)
        @client[@collection].find(query.selector, query.options)
      end
    end
  end
end
