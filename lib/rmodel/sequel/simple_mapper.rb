module Rmodel::Sequel
  class SimpleMapper
    def initialize(klass, *attributes)
      @klass = klass
      @attributes = attributes
    end

    def deserialize(hash)
      object = @klass.new
      object.id = hash[:id]
      @attributes.each do |attribute|
        object.public_send "#{attribute}=", hash[attribute.to_sym]
      end
      object
    end

    def serialize(object, id_included)
      hash = {}
      @attributes.each do |attribute|
        hash[attribute.to_sym] = object.public_send(attribute)
      end
      if id_included
        hash[:id] = object.id
      end
      hash
    end
  end
end
