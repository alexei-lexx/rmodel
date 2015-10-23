require 'rmodel/mongo/repository_ext/query'

module Rmodel::Mongo
  module RepositoryExt
    module Queryable
      def query
        (self.class.query_klass ||= Class.new(Query)).new(self)
      end

      def find_by_query(selector, options)
        execute_query(selector, options).map do |hash|
          factory.fromHash(hash)
        end
      end

      def execute_query(selector, options)
        self.client[collection].find(selector, options)
      end

      def self.included(base)
        base.extend ClassMethods
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
