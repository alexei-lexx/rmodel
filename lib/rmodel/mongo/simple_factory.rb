module Rmodel::Mongo
  class SimpleFactory
    def initialize(klass, *attributes, &block)
      @klass = klass
      @attributes = attributes
      @embeds_many = {}
      @embeds_one = {}
      instance_eval(&block) if block
    end

    def fromHash(hash)
      object = @klass.new
      object.id = hash['_id']
      @attributes.each do |attribute|
        object.public_send "#{attribute}=", hash[attribute.to_s]
      end
      @embeds_many.each do |attribute, factory|
        if hash[attribute.to_s]
          object.public_send "#{attribute}=", []
          hash[attribute.to_s].each do |sub_hash|
            object.public_send(attribute) << factory.fromHash(sub_hash)
          end
        end
      end
      @embeds_one.each do |attribute, factory|
        sub_hash = hash[attribute.to_s]
        if sub_hash
          object.public_send "#{attribute}=", factory.fromHash(sub_hash)
        end
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
      @embeds_many.each do |attribute, factory|
        hash[attribute.to_s] = []
        sub_objects = object.public_send(attribute)
        if sub_objects
          sub_objects.each do |sub_object|
            sub_object.id ||= BSON::ObjectId.new
            hash[attribute.to_s] << factory.toHash(sub_object, true)
          end
        end
      end
      @embeds_one.each do |attribute, factory|
        sub_object = object.public_send(attribute)
        if sub_object
          sub_object.id ||= BSON::ObjectId.new
          hash[attribute.to_s] = factory.toHash(sub_object, true)
        end
      end
      hash
    end

    private

    def embeds_many(attribute, factory, &block)
      factory.instance_eval(&block) if block
      @embeds_many[attribute.to_sym] = factory
    end

    def embeds_one(attribute, factory, &block)
      factory.instance_eval(&block) if block
      @embeds_one[attribute.to_sym] = factory
    end

    def simple_factory(klass, *attributes, &block)
      self.class.new(klass, *attributes, &block)
    end
  end
end
