module Rmodel::Base
  module RepositoryExt
    module Queryable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def query_klass
          @query_klass ||= Class.new(Rmodel::Base::QueryBuilder)
        end

        def scope(name, &block)
          self.query_klass.define_scope(name, &block)
        end
      end
    end
  end
end
