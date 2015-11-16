module Rmodel::Sequel
  class Mapper
    def initialize
      if model.nil?
        raise ArgumentError.new('Model was not declared')
      end
    end

    def deserialize(hash)
      object = model.new
      object.id = hash[:id]
      attributes.each do |attribute|
        object.public_send "#{attribute}=", hash[attribute.to_sym]
      end
      object
    end

    def serialize(object, id_included)
      hash = {}
      attributes.each do |attribute|
        hash[attribute.to_sym] = object.public_send(attribute)
      end
      if id_included
        hash[:id] = object.id
      end
      hash
    end

    private

    def model
      self.class.declared_model
    end

    def attributes
      self.class.declared_attributes || []
    end

    class << self
      attr_reader :declared_model, :declared_attributes

      def model(klass)
        @declared_model = klass
      end

      def attributes(*attributes)
        @declared_attributes = attributes
      end
    end
  end
end
