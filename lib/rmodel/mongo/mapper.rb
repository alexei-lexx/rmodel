module Rmodel::Mongo
  class Mapper < Rmodel::Base::Mapper
    def initialize
      super
      self.primary_key = '_id'
    end

    def deserialize(hash)
      object = model.new
      if object.respond_to?(:id)
        object.id = hash[primary_key]
      end
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
      if id_included && object.respond_to?(:id)
        hash[primary_key] = object.id
      end
      hash
    end

    private

    def attributes
      self.class.declared_attributes || {}
    end

    class << self
      attr_reader :declared_attributes

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
