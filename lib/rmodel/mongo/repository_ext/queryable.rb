module Rmodel
  module Mongo
    module RepositoryExt
      module Queryable
        def remove_by_query(query)
          @source.exec_query(query).delete_many
        end
      end
    end
  end
end
