module Rmodel
  module Mongo
    class Mapper < Rmodel::BaseMapper
      def initialize(model)
        super
        self.primary_key = '_id'
        self.key_op = :to_s
      end
    end
  end
end
