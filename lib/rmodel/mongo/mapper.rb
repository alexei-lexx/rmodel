module Rmodel::Mongo
  class Mapper
    def initialize
      @model = self.class.declared_model
      @attributes = self.class.declared_attributes || []
      @embeds_one = self.class.declared_embeds_one || {}
      @embeds_many = self.class.declared_embeds_many || {}
    end

    def deserialize(hash)
      object = @model.new
      object.id = hash['_id']
      @attributes.each do |attribute, mapper_klass|
        object.public_send "#{attribute}=", hash[attribute.to_s]
      end
      @embeds_one.each do |attribute, mapper_klass|
        sub_hash = hash[attribute.to_s]
        if sub_hash
          object.public_send "#{attribute}=", mapper_klass.new.deserialize(sub_hash)
        end
      end
      @embeds_many.each do |attribute, mapper_klass|
        array = hash[attribute.to_s]
        if array
          sub_objects = array.map { |entry| mapper_klass.new.deserialize(entry) }
          object.public_send "#{attribute}=", sub_objects
        end
      end
      object
    end

    def to_hash(object, id_included)
      hash = {}
      @attributes.each do |attribute, mapper_klass|
        hash[attribute.to_s] = object.public_send(attribute)
      end
      if id_included
        hash['_id'] = object.id
      end
      @embeds_one.each do |attribute, mapper_klass|
        sub_object = object.public_send(attribute)
        if sub_object
          hash[attribute.to_s] = mapper_klass.new.to_hash(sub_object, true)
        end
      end
      @embeds_many.each do |attribute, mapper_klass|
        hash[attribute.to_s] = []
        sub_objects = object.public_send(attribute)
        if sub_objects
          sub_objects.each do |sub_object|
            hash[attribute.to_s] << mapper_klass.new.to_hash(sub_object, true)
          end
        end
      end
      hash
    end

    class << self
      attr_reader :declared_model, :declared_attributes,
                  :declared_embeds_one, :declared_embeds_many

      def model(klass)
        @declared_model = klass
      end

      def attributes(*attributes)
        @declared_attributes = attributes;
      end

      def embeds_one(attribute, mapper_klass)
        @declared_embeds_one ||= {}
        @declared_embeds_one[attribute] = mapper_klass
      end

      def embeds_many(attribute, mapper_klass)
        @declared_embeds_many ||= {}
        @declared_embeds_many[attribute] = mapper_klass
      end
    end
  end
end
