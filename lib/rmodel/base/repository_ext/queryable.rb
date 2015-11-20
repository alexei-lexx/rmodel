module Rmodel
  module Base
    module RepositoryExt
      module Queryable
        def self.included(base)
          base.extend ClassMethods
        end

        def query
          self.class.query_klass.new(self, @source.build_query)
        end

        def destroy_by_query(query)
          @source.exec_query(query).map do |hash|
            object = @mapper.deserialize(hash)
            destroy(object)
          end
        end

        module ClassMethods
          def query_klass
            @query_klass ||= Class.new(Rmodel::Base::QueryBuilder)
          end

          def scope(name, &block)
            query_klass.define_scope(name, &block)
          end
        end
      end
    end
  end
end
