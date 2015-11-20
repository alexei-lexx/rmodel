module Rmodel
  module Mongo
    class Repository < Rmodel::Base::Repository
      def initialize(client = nil, collection = nil, mapper = nil)
        client = client || self.class.declared_client_name || :default
        collection = collection || self.class.declared_collection ||
                     self.class.collection_by_convention

        super Source.new(client, collection), mapper
      end

      def find(id)
        query.scope { where(_id: id) }.first
      end

      class << self
        attr_reader :declared_collection

        def collection(name)
          @declared_collection = name
        end

        def collection_by_convention
          return unless name =~ /(.*)Repository$/
          model_name = Regexp.last_match(1)
          ActiveSupport::Inflector.tableize(model_name).to_sym
        end
      end
    end
  end
end
