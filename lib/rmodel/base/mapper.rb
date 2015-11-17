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
      object = model.new
      if object.respond_to?(:id)
        object.id = hash[primary_key.send(key_op)]
      end
      attributes.each do |attribute, mapper|
        raw_value = hash[attribute.send(key_op)]
        if mapper && raw_value
          object.public_send "#{attribute}=", mapper.deserialize(raw_value)
        else
          object.public_send "#{attribute}=", raw_value
        end

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
        hash[attribute.send(key_op)] = value
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
          ActiveSupport::Inflector.constantize($1).new
        end
      rescue NameError
        nil
      end

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
