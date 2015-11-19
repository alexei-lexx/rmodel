module Rmodel
  module Base
    class DummyMapper
      def serialize(arg, _id_included)
        arg
      end

      def deserialize(arg)
        arg
      end
    end
  end
end
