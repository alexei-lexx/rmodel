require 'origin'

module Rmodel
  module Mongo
    class Query
      include Origin::Queryable

      def find_by_id(id)
        where('_id' => id)
      end
    end
  end
end
