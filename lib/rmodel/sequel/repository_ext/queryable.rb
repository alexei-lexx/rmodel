module Rmodel
  module Sequel
    module RepositoryExt
      module Queryable
        def find_by_query(query)
          query.map do |hash|
            @mapper.deserialize(hash)
          end
        end

        def remove_by_query(query)
          query.delete
        end

        def destroy_by_query(query)
          query.map do |hash|
            object = @mapper.deserialize(hash)
            destroy(object)
          end
        end
      end
    end
  end
end
