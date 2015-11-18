require 'origin'

module Rmodel
  module Mongo
    module RepositoryExt
      module Queryable
        class Query
          include Origin::Queryable
        end

        def query
          self.class.query_klass.new(self, Query.new)
        end

        def find_by_query(query)
          execute_query(query).map do |hash|
            @mapper.deserialize(hash)
          end
        end

        def remove_by_query(query)
          execute_query(query).delete_many
        end

        def destroy_by_query(query)
          execute_query(query).map do |hash|
            object = @mapper.deserialize(hash)
            destroy(object)
          end
        end

        private

        def execute_query(query)
          @client[@collection].find(query.selector, query.options)
        end
      end
    end
  end
end
