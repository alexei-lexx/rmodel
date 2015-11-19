module Rmodel
  module Sequel
    module RepositoryExt
      module Queryable
        def query
          self.class.query_klass.new(self, @client[@table])
        end

        def find_by_query(dataset)
          dataset.map do |hash|
            @mapper.deserialize(hash)
          end
        end

        def remove_by_query(dataset)
          dataset.delete
        end

        def destroy_by_query(dataset)
          dataset.map do |hash|
            object = @mapper.deserialize(hash)
            destroy(object)
          end
        end
      end
    end
  end
end
