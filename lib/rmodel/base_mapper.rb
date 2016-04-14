module Rmodel
  class BaseMapper
    def initialize(model)
      @model = model
      self.primary_key = :id
      self.key_op = :to_sym
      @attributes = {}
    end

    def define_attribute(attr, mapper = DummyMapper.new)
      @attributes[attr] = mapper
      self
    end

    def define_attributes(*attributes)
      attributes.each { |attr| define_attribute(attr) }
      self
    end

    def deserialize(hash)
      return nil if hash.nil?

      uni_hash = UniHash.new(hash, key_op)

      object = @model.new
      object.id = uni_hash[primary_key] if object.respond_to?(:id)
      @attributes.each do |attr, mapper|
        deserialized = mapper.deserialize(uni_hash[attr])
        object.public_send "#{attr}=", deserialized
      end
      object
    end

    def serialize(object, id_included)
      return nil if object.nil?

      uni_hash = UniHash.new({}, key_op)
      @attributes.each do |attr, mapper|
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
  end
end
