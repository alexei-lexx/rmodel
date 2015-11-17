module Rmodel::Base
  class Mapper
    def initialize
      if model.nil?
        raise ArgumentError.new('Model was not declared')
      end
      self.primary_key = :id
      self.key_op = :to_sym
    end

    def deserialize(hash)
      return nil if hash.nil?

      object = model.new
      if object.respond_to?(:id)
        object.id = hash[primary_key.send(key_op)]
      end
      attributes.each do |attribute, mapper|
        deserialized_value = mapper.deserialize(hash[attribute.send(key_op)])
        object.public_send "#{attribute}=", deserialized_value
      end
      object
    end

    def serialize(object, id_included)
      return nil if object.nil?

      hash = {}
      attributes.each do |attribute, mapper|
        serialized_value = mapper.serialize(object.public_send(attribute), true)
        hash[attribute.send(key_op)] = serialized_value
      end
      if id_included && object.respond_to?(:id)
        hash[primary_key.send(key_op)] = object.id
      end
      hash
    end

    private

    attr_accessor :primary_key
    attr_accessor :key_op

    def model
      self.class.declared_model || self.class.model_by_convention
    end

    def attributes
      self.class.declared_attributes || {}
    end

    class << self
      attr_reader :declared_model

      def model(klass)
        @declared_model = klass
      end

      def model_by_convention
        if name =~ /(.*)Mapper$/
          ActiveSupport::Inflector.constantize($1)
        end
      rescue NameError
        nil
      end

      attr_reader :declared_attributes

      def attribute(attr, mapper = nil)
        @dummy_mapper ||= DummyMapper.new
        @declared_attributes ||= {}
        @declared_attributes[attr] = mapper || @dummy_mapper
      end

      def attributes(*attributes)
        attributes.each do |attr|
          attribute(attr, nil)
        end
      end
    end
  end
end
