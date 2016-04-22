require 'singleton'

module Rmodel
  class DummyMapper
    include Singleton

    def serialize(arg, _id_included)
      arg
    end

    def deserialize(arg)
      arg
    end
  end
end
