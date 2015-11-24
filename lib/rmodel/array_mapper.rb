module Rmodel
  class ArrayMapper
    def initialize(mapper)
      @mapper = mapper
    end

    def serialize(objects, id_included)
      if objects.nil?
        nil
      else
        objects.map { |object| @mapper.serialize(object, id_included) }
      end
    end

    def deserialize(array)
      if array.nil?
        nil
      else
        array.map { |entry| @mapper.deserialize(entry) }
      end
    end
  end
end
