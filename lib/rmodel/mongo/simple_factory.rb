module Rmodel::Mongo
  class SimpleFactory
    def initialize(klass, *attributes)
      @klass = klass
      @attributes = attributes
    end

    def fromHash(hash)
      object = @klass.new
      object.id = hash['_id']
      @attributes.each do |attribute|
        object.public_send "#{attribute}=", hash[attribute.to_s]
      end
      object
    end

    def toHash(object, id_included)
      hash = {}
      @attributes.each do |attribute|
        hash[attribute.to_s] = object.public_send(attribute)
      end
      if id_included
        hash['_id'] = object.id
      end
      hash
    end
  end
end
