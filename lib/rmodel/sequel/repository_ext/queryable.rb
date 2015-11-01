module Rmodel::Sequel
  module RepositoryExt
    module Queryable
      def self.included(base)
        base.extend ClassMethods
      end

      def query
        (self.class.query_klass ||= Class.new(Rmodel::Base::QueryBuilder)).new(self, @client[@table])
      end

      def find_by_query(dataset)
        dataset.map do |hash|
          @factory.fromHash(hash)
        end
      end

      def remove_by_query(dataset)
        dataset.delete
      end

      def destroy_by_query(dataset)
        dataset.map do |hash|
          object = @factory.fromHash(hash)
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
    end
  end
end
