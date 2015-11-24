module Rmodel
  class BaseMapper
    def initialize
      fail ArgumentError, 'Model was not declared' if model.nil?
      self.primary_key = :id
      self.key_op = :to_sym
    end

    def deserialize(hash)
      return nil if hash.nil?

      uni_hash = UniHash.new(hash, key_op)

      object = model.new
      object.id = uni_hash[primary_key] if object.respond_to?(:id)
      attributes.each do |attr, mapper|
        deserialized = mapper.deserialize(uni_hash[attr])
        object.public_send "#{attr}=", deserialized
      end
      object
    end

    def serialize(object, id_included)
      return nil if object.nil?

      uni_hash = UniHash.new({}, key_op)
      attributes.each do |attr, mapper|
        serialized = mapper.serialize(object.public_send(attr), id_included)
        uni_hash[attr] = serialized
      end
      if id_included && object.respond_to?(:id)
        uni_hash[primary_key] = object.id
      end
      uni_hash.to_hash
    end

    private

    attr_accessor :primary_key, :key_op

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
          model_name = Regexp.last_match(1)
          ActiveSupport::Inflector.constantize(model_name)
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
