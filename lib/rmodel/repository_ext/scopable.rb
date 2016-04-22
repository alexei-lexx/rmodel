module Rmodel
  module RepositoryExt
    module Scopable
      def self.included(base)
        base.extend ClassMethods
      end

      def query
        self.class.scope_class.new(self, @source.build_query)
      end

      def find_by_scope(scope)
        raw_query = scope.raw_query

        @source.exec_query(raw_query).map do |hash|
          @mapper.deserialize(hash)
        end
      end

      def delete_by_scope(scope)
        raw_query = scope.raw_query
        @source.delete_by_query(raw_query)
      end

      module ClassMethods
        def scope_class
          @scope_class ||= Class.new(Rmodel::Scope)
        end

        def scope(name, &block)
          scope_class.define_scope(name, &block)
        end
      end
    end
  end
end
