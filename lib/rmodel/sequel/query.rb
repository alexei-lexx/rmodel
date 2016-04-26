require 'origin'

module Rmodel
  module Sequel
    class Query < SimpleDelegator
      def find_by_id(id)
        where(id: id)
      end
    end
  end
end
