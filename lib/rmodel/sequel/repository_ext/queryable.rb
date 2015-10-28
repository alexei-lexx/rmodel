require 'rmodel/sequel/repository_ext/query'

module Rmodel::Sequel
  module RepositoryExt
    module Queryable
      def self.included(base)
        base.extend ClassMethods
      end

      def query
        (self.class.query_klass ||= Class.new(Query)).new(self, @client[@table])
      end

      def find_by_query(dataset)
        dataset.map do |hash|
          @factory.fromHash(hash)
        end
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
