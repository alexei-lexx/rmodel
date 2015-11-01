require 'rmodel/mongo/repository_ext/query'

module Rmodel::Mongo
  module RepositoryExt
    module Queryable
      def self.included(base)
        base.extend ClassMethods
      end

      def query
        (self.class.query_klass ||= Class.new(Query)).new(self)
      end

      def find_by_query(queryable)
        execute_query(queryable).map do |hash|
          @factory.fromHash(hash)
        end
      end

      def destroy_by_query(queryable)
        execute_query(queryable).map do |hash|
          object = @factory.fromHash(hash)
          destroy(object)
        end
      end

      def execute_query(queryable)
        @client[@collection].find(queryable.selector, queryable.options)
      end

      module ClassMethods
        attr_accessor :query_klass

        def scope(name, &block)
          self.query_klass ||= Class.new(Query)
          self.query_klass.define_scope(name, &block)
        end
      end
    end
  end
end
