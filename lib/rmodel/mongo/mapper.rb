module Rmodel::Mongo
  class Mapper
    def initialize
      if model.nil?
        raise ArgumentError.new('Model was not declared')
      end
    end

    def deserialize(hash)
      object = model.new
      object.id = hash['_id']
      attributes.each do |attribute, mapper|
        if mapper && hash[attribute.to_s]
          value = mapper.deserialize(hash[attribute.to_s])
        else
          value = hash[attribute.to_s]
        end
        object.public_send "#{attribute}=", value
      end
      object
    end

    def serialize(object, id_included)
      hash = {}
      attributes.each do |attribute, mapper|
        if mapper && object.public_send(attribute)
          value = mapper.serialize(object.public_send(attribute), true)
        else
          value = object.public_send(attribute)
        end
        hash[attribute.to_s] = value
      end
      if id_included
        hash['_id'] = object.id
      end
      hash
    end

    private

    def model
      self.class.declared_model
    end

    def attributes
      self.class.declared_attributes || {}
    end

    class << self
      attr_reader :declared_model, :declared_attributes

      def model(klass)
        @declared_model = klass
      end

      def attribute(attr, mapper = nil)
        @declared_attributes ||= {}
        @declared_attributes[attr] = mapper
      end

      def attributes(*attributes)
        attributes.each do |attr|
          attribute(attr, nil)
        end
      end
    end
  end
end
