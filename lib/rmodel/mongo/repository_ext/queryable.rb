require 'rmodel/mongo/repository_ext/query'

module Rmodel::Mongo
  module RepositoryExt
    module Queryable
      def query
        self.class.query_klass.new(self)
      end

      def execute_query(queryable)
        self.session[collection].find(queryable.selector, queryable.options)
      end

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        attr_accessor :query_klass

        def scope(name, &block)
          self.query_klass ||= Class.new(Query)

          self.query_klass.class_eval do
            define_method name do |*args|
              new_queryable = @queryable.instance_exec(*args, &block)
              self.class.new(@repo, new_queryable)
            end
          end
        end
      end
    end
  end
end
