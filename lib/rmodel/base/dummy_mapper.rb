module Rmodel::Base
  class DummyMapper
    def serialize(arg, id_included)
      arg
    end

    def deserialize(arg)
      arg
    end
  end
end
