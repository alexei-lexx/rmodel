require 'rmodel/mongo/repository_ext/query'

module Rmodel::Mongo
  module RepositoryExt
    module Queryable
      def query
        (self.class.query_klass ||= Class.new(Query)).new(self)
      end

      def execute_query(selector, options)
        self.session[collection].find(selector, options)
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
