module Rmodel
  module Sequel
    module RepositoryExt
      module Queryable
        def find_by_query(query)
          @source.exec_query(query).map do |hash|
            @mapper.deserialize(hash)
          end
        end

        def remove_by_query(query)
          @source.exec_query(query).delete
        end
      end
    end
  end
end
