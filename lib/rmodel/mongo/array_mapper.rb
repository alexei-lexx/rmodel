module Rmodel::Mongo
  class ArrayMapper
    def initialize(mapper)
      @mapper = mapper
    end

    def serialize(objects, id_included)
      objects.map { |object| @mapper.serialize(object, id_included) }
    end

    def deserialize(array)
      array.map { |entry| @mapper.deserialize(entry) }
    end
  end
end
