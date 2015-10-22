require 'rmodel/mongo/repository_ext/query'

module Rmodel::Mongo
  module RepositoryExt
    module Queryable
      def query
        Query.new(self)
      end

      def execute_query(queryable)
        self.session[collection].find(queryable.selector, queryable.options)
      end

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        attr_accessor :scopes

        def scope(name, &block)
          self.scopes ||= {}
          self.scopes[name.to_sym] = block
        end
      end
    end
  end
end
