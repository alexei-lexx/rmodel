module Rmodel
  module RepositoryExt
    module Scopable
      def self.included(base)
        base.extend ClassMethods
      end

      def fetch
        self.class.scope_class.new(self, @source.build_query)
      end

      def find_all(scope = nil)
        raw_query = (scope || fetch).raw_query

        @source.exec_query(raw_query).map do |hash|
          @mapper.deserialize(hash)
        end
      end

      def delete_all(scope = nil)
        raw_query = (scope || fetch).raw_query
        @source.delete_by_query(raw_query)
      end

      def destroy_all(scope = nil)
        find_all(scope).each { |object| destroy(object) }
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
