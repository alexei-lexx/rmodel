module Rmodel
  module Sequel
    module RepositoryExt
      module Queryable
        def delete_by_query(query)
          @source.exec_query(query).delete
        end
      end
    end
  end
end
