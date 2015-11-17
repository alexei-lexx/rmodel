module Rmodel::Mongo
  class Mapper < Rmodel::Base::Mapper
    def initialize
      super
      self.primary_key = '_id'
      self.key_op = :to_s
    end
  end
end
