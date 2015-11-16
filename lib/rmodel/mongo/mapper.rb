module Rmodel::Mongo
  class Mapper
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
      embeds_many.each do |attribute, mapper|
        array = hash[attribute.to_s]
        if array
          sub_objects = array.map { |entry| mapper.deserialize(entry) }
          object.public_send "#{attribute}=", sub_objects
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
        hash[attribute.to_s] = value
      end
      if id_included
        hash['_id'] = object.id
      end
      embeds_many.each do |attribute, mapper|
        hash[attribute.to_s] = []
        sub_objects = object.public_send(attribute)
        if sub_objects
          sub_objects.each do |sub_object|
            hash[attribute.to_s] << mapper.serialize(sub_object, true)
          end
        end
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

    def embeds_many
       self.class.declared_embeds_many || {}
    end

    class << self
      attr_reader :declared_model, :declared_attributes,
                  :declared_embeds_many

      def model(klass)
        @declared_model = klass
      end

      def attribute(attr, mapper)
        @declared_attributes ||= {}
        @declared_attributes[attr] = mapper
      end

      def attributes(*attributes)
        attributes.each do |attr|
          attribute(attr, nil)
        end
      end

      def embeds_many(attribute, mapper)
        @declared_embeds_many ||= {}
        @declared_embeds_many[attribute] = mapper
      end
    end
  end
end
